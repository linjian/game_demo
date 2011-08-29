class CityResource < ActiveRecord::Base
  DEFAULT_POPULATION = 100
  DEFAULT_TAX_RATE = 20

  NORMAL_FOOD_OUTPUT  = 1000  # per hour
  CAPITAL_FOOD_OUTPUT = 10000 # per hour

  POPULATION_INCREASE_LOWER_LIMIT = 1
  POPULATION_DECREASE_LOWER_LIMIT = 1
  POPULATION_INCREASE_UPPER_LIMIT = 1000
  POPULATION_DECREASE_UPPER_LIMIT = 1000
  POPULATION_INCREASE_RATE = 5
  POPULATION_DECREASE_RATE = 5

  belongs_to :user
  belongs_to :city

  validates_numericality_of :food,
    :greater_than_or_equal_to => 0
  validates_numericality_of :gold,
    :only_integer             => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :population,
    :only_integer             => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :tax_rate,
    :only_integer             => true,
    :greater_than_or_equal_to => 0

  before_create :set_user_id
  before_create :set_default_values

  after_create :collect_tax

  class << self
    def population_increase_lower_limit
      POPULATION_INCREASE_LOWER_LIMIT
    end

    def population_decrease_lower_limit
      POPULATION_DECREASE_LOWER_LIMIT
    end

    def population_increase_upper_limit
      POPULATION_INCREASE_UPPER_LIMIT
    end

    def population_decrease_upper_limit
      POPULATION_DECREASE_UPPER_LIMIT
    end

    def population_increase_rate
      POPULATION_INCREASE_RATE
    end

    def population_decrease_rate
      POPULATION_DECREASE_RATE
    end
  end

  def food_output
    city.is_capital? ? CAPITAL_FOOD_OUTPUT : NORMAL_FOOD_OUTPUT
  end

  def food_output_rate
    food_output.to_f / 1.hour
  end

  def set_user_id
    self.user_id = city.user_id
  end

  def set_default_values
    self.food ||= 0
    self.gold ||= 0
    self.population ||= 100
    self.tax_rate ||= 20
  end

  def update_food
    now = Time.now.utc
    food = calculate_food(now)
    self.update_attributes(:food => food, :food_updated_time => now)
    self.food.to_i
  end

  def calculate_food(now)
    duration = now - (food_updated_time || created_at)
    duration * self.food_output_rate + self.food
  end

  def collect_tax
    init_last_taxation_time

    past_hours = (Time.now.utc - self.last_taxation_time).to_i / 1.hour
    past_hours.times { collect_tax_by_hour }

    self.save
  end

  def collect_tax_by_hour(save = false)
    init_last_taxation_time

    decrease_gold_for_taxation
    calculate_population_for_taxation
    supply_food_for_armies
    self.last_taxation_time += 1.hours

    self.save if save
  end

  def init_last_taxation_time
    self.last_taxation_time ||= self.created_at - 1.hour
  end

  def decrease_gold_for_taxation
    self.gold = (self.gold * (1 - tax_rate / 100.0)).to_i
  end

  def calculate_population_for_taxation
    if decrease_population_for_taxation?
      decrease_population_for_taxation
      adjust_army_training_queues_by_population
    else
      increase_population_for_taxation
    end
  end

  def decrease_population_for_taxation?
    self.population > tax_rate * 1000 / 100
  end

  [:increase, :decrease].each do |type|
    define_method :"#{type}_population_for_taxation" do
      delta = (self.population * self.class.send(:"population_#{type}_rate") / 100.0)
      delta = [delta, self.class.send(:"population_#{type}_lower_limit")].max
      delta = [delta, self.class.send(:"population_#{type}_upper_limit")].min
      self.population = self.send(:"#{type}d_population", delta).to_i
    end
  end

  def increased_population(delta)
    self.population + delta
  end

  def decreased_population(delta)
    self.population - delta
  end

  def with_tax_collection
    collect_tax
    yield
  end

  def get_resource
    with_tax_collection do
      resource = {}
      resource[:food] = self.update_food
      resource[:gold] = self.gold
      resource[:population] = self.population
      resource[:tax_rate] = self.tax_rate
      resource
    end
  end

  def get_gold
    with_tax_collection do
      self.gold
    end
  end

  def get_population
    with_tax_collection do
      self.population
    end
  end

  def change_tax_rate(new_rate)
    with_tax_collection do
      self.update_attributes(:tax_rate => new_rate) && new_rate
    end
  end

  def adjust_army_training_queues_by_population
    medium_city = self.medium_city
    medium_city.adjust_army_training_queues_by_population if medium_city
  end

  def supply_food_for_armies
    return unless medium_city = self.medium_city

    city_food = self.update_food
    armies_food_consumption = medium_city.armies_food_consumption

    delta = city_food - armies_food_consumption
    self.update_attribute(:food, [delta, 0].max)
    medium_city.decreased_armies_amount if delta < 0

    medium_city.clean_food_consumption
  end

  def medium_city
    MediumCity.find(city.id) if city.city_type == MediumCity::CITY_TYPE
  end
end
