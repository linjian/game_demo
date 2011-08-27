class CityResource < ActiveRecord::Base
  DEFAULT_POPULATION = 100
  DEFAULT_TAX_RATE = 20
  NORMAL_FOOD_OUTPUT = 1000 # per hour

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

  class << self
    def food_output
      NORMAL_FOOD_OUTPUT
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

  def extract_hours_and_remainder(since)
    duration = (Time.now.utc - since).to_i
    past_hours = duration / 1.hour
    remainder = duration % 1.hour
    [past_hours, remainder]
  end
end
