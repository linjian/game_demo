class CityResource < ActiveRecord::Base
  DEFAULT_POPULATION = 100
  DEFAULT_TAX_RATE = 20
  NORMAL_FOOD_OUTPUT = 1000 # per hour

  POPULATION_INCREASE_LOWER_LIMIT = 1
  POPULATION_DECREASE_LOWER_LIMIT = 1
  POPULATION_INCREASE_UPPER_LIMIT = 1000
  POPULATION_DECREASE_UPPER_LIMIT = 1000
  POPULATION_INCREASE_RATE = 5
  POPULATION_DECREASE_RATE = 5

  belongs_to :user
  belongs_to :city

  validates_numericality_of :food,
    :only_integer             => true,
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
    def food_output
      NORMAL_FOOD_OUTPUT
    end

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

  def set_user_id
    self.user_id = city.user.id
  end

  def set_default_values
    self.food ||= 0
    self.gold ||= 0
    self.population ||= 100
    self.tax_rate ||= 20
  end

  def get_food
    past_hours, remainder = extract_hours_and_remainder(last_food_updated_time)
    set_food_by_hours(past_hours)
    self.food + remainder * self.class.food_output / 1.hour
  end

  def set_food_by_hours(past_hours)
    if past_hours > 0
      self.food += past_hours * self.class.food_output
      self.food_updated_time = last_food_updated_time + past_hours.hours
      self.save
    end
  end

  def last_food_updated_time
    food_updated_time || created_at
  end

  def collect_tax
    init_last_taxation_time

    past_hours = extract_hours_and_remainder(self.last_taxation_time).first
    past_hours.times { collect_tax_by_hour }

    self.save
  end

  def collect_tax_by_hour(save = false)
    init_last_taxation_time

    decrease_gold_for_taxation
    calculate_population_for_taxation
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
      resource[:food] = self.get_food
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

  def extract_hours_and_remainder(since)
    duration = (Time.now.utc - since).to_i
    past_hours = duration / 1.hour
    remainder = duration % 1.hour
    [past_hours, remainder]
  end
end
