class CityResource < ActiveRecord::Base
  DEFAULT_POPULATION = 100
  DEFAULT_TAX_RATE = 20

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

  def set_user_id
    self.user_id = city.user.id
  end

  def set_default_values
    self.food ||= 0
    self.gold ||= 0
    self.population ||= 100
    self.tax_rate ||= 20
  end
end
