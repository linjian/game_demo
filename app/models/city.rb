class City < ActiveRecord::Base
  belongs_to :user

  has_one :city_resource, :dependent => :destroy

  validates_numericality_of :area_left_value,
    :only_integer             => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :area_bottom_value,
    :only_integer             => true,
    :greater_than_or_equal_to => 0

  validate :check_overlap

  before_create :init_city_resource

  delegate :change_tax_rate, :to => :city_resource
  delegate :get_population,  :to => :city_resource

  config_class_methods :city_side_length

  def check_overlap
    errors.add(:base, "overlaped with other cities") if overlap?
  end

  def init_city_resource
    self.build_city_resource
  end

  def area_right_value
    area_left_value + self.class.city_side_length - 1
  end

  def area_top_value
    area_bottom_value + self.class.city_side_length - 1
  end

  def sibling_cities
    user.cities - [self]
  end

  def overlap?
    sibling_cities.any? do |city|
      !(self.area_right_value < city.area_left_value ||
        self.area_left_value > city.area_right_value ||
        self.area_top_value < city.area_bottom_value ||
        self.area_bottom_value > city.area_top_value)
    end
  end

  def get_current_city_resource
    city_resource.get_resource
  end

  def become_capital
    old_capital_sibling = get_capital_sibling

    old_capital_sibling.mark_capital(false) if old_capital_sibling
    self.mark_capital(true)
  end

  def mark_capital(is_capital)
    self.city_resource.update_food
    self.update_attributes(:is_capital => is_capital)
  end

  def get_capital_sibling
    self.user.cities.detect(&:is_capital)
  end

  def become_medium_city
    return self if self.instance_of?(MediumCity) && self.is_medium_city?
    self.update_attributes(:city_type => MediumCity.medium_city_type)
    MediumCity.find(self.id)
  end

  def is_medium_city?
    self.city_type == MediumCity.medium_city_type
  end
end
