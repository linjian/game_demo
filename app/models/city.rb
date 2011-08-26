class City < ActiveRecord::Base
  SIDE_LENGTH = 100

  belongs_to :user

  validates_numericality_of :area_left_value,
    :only_integer             => true,
    :greater_than_or_equal_to => 0
  validates_numericality_of :area_bottom_value,
    :only_integer             => true,
    :greater_than_or_equal_to => 0

  validate :check_overlap

  def check_overlap
    errors.add(:base, "overlaped with other cities") if overlap?
  end

  def area_right_value
    area_left_value + SIDE_LENGTH - 1
  end

  def area_top_value
    area_bottom_value + SIDE_LENGTH - 1
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
end
