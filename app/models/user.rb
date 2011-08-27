class User < ActiveRecord::Base
  MAXIMUM_CITY_COUNT = 10

  has_many :cities, :dependent => :destroy
  has_many :city_resources

  validates_presence_of :login, :password

  def add_city(city_attrs)
    return false unless check_city_count
    new_city = self.cities.create(city_attrs)
    errors.add(:city, new_city.errors.full_messages.join(". ")) if new_city.invalid?
    new_city.valid?
  end

  def check_city_count
    hit_max = (cities.size >= MAXIMUM_CITY_COUNT)
    errors.add(:city, "can only be at most #{MAXIMUM_CITY_COUNT}") if hit_max
    !hit_max
  end
end
