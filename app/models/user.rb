class User < ActiveRecord::Base
  MAXIMUM_CITY_COUNT = 10

  has_many :cities, :dependent => :destroy

  validates_presence_of :login, :password

  def add_city(city_attrs)
    return false unless check_city_count
    new_city = self.cities.create(city_attrs)
    errors.add(:city, new_city.errors.full_messages.join(". ")) if new_city.invalid?
    new_city.valid? ? new_city : false
  end

  def check_city_count
    hit_max = (cities.size >= MAXIMUM_CITY_COUNT)
    errors.add(:city, "can only have at most #{MAXIMUM_CITY_COUNT}") if hit_max
    !hit_max
  end

  def get_all_current_city_resources
    cities.inject({}) do |resources, city|
      resources.merge(city.id.to_s => city.get_current_city_resource)
    end
  end
end
