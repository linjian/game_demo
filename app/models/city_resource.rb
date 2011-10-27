class CityResource < ActiveRecord::Base
  include MediumCityResource

  belongs_to :user
  belongs_to :city

  validates_presence_of :city_id, :user_id
  validates :food,
    :numericality => {:greater_than_or_equal_to => 0}
  validates :gold,
    :numericality => {:greater_than_or_equal_to => 0,
                      :only_integer             => true}
  validates :population,
    :numericality => {:greater_than_or_equal_to => 0,
                      :only_integer             => true}
  validates :tax_rate,
    :numericality => {:greater_than_or_equal_to => 0}

  before_validation :set_user_id

  before_create :set_default_values

  after_create :collect_tax

  config_class_methods :default_population, :default_tax_rate,
                       :normal_food_output, :capital_food_output,
                       :population_increase_lower_limit, :population_decrease_lower_limit,
                       :population_increase_upper_limit, :population_decrease_upper_limit,
                       :population_increase_rate,        :population_decrease_rate

  def food_output
    city.is_capital? ? self.class.capital_food_output : self.class.normal_food_output
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
    self.population ||= self.class.default_population
    self.tax_rate ||= self.class.default_tax_rate
  end

  def update_food
    now = Time.now.utc
    self.update_attributes(:food => calculate_food(now), :food_updated_time => now)
    self.food.to_i
  end

  alias_method :city_food, :update_food

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

  def collect_tax_by_hour
    decrease_gold_for_taxation
    calculate_population_for_taxation
    supply_food_for_armies
    self.last_taxation_time += 1.hours
  end

  def init_last_taxation_time
    self.last_taxation_time ||= self.created_at - 1.hour
  end

  def decrease_gold_for_taxation
    self.gold = (self.gold * (1 - tax_rate)).to_i
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
    self.population > tax_rate * 1000
  end

  [:increase, :decrease].each do |type|
    define_method :"#{type}_population_for_taxation" do
      delta = self.population * self.class.send(:"population_#{type}_rate")
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
    with_tax_collection { self.gold }
  end

  def get_population
    with_tax_collection { self.population }
  end

  def change_tax_rate(new_rate)
    with_tax_collection do
      self.update_attributes(:tax_rate => new_rate) && new_rate
    end
  end
end
