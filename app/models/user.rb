class User < ActiveRecord::Base
  has_many :cities, :dependent => :destroy
  has_many :medium_cities, :dependent => :destroy,
    :foreign_key => "user_id",
    :conditions  => {:city_type => MediumCity.medium_city_type}

  validates :login, :password, :presence => true

  config_class_methods :maximum_city_count

  def add_city(city_attrs)
    return false unless check_city_count
    new_city = self.cities.create(city_attrs)
    errors.add(:city, new_city.errors.full_messages.join(". ")) if new_city.invalid?
    new_city.valid? ? new_city : false
  end

  def check_city_count
    hit_max = (cities.size >= self.class.maximum_city_count)
    errors.add(:city, "can only have at most #{self.class.maximum_city_count}") if hit_max
    !hit_max
  end

  def get_all_current_city_resources
    cities.inject({}) do |resources, city|
      resources.merge(city.id.to_s => city.get_current_city_resource)
    end
  end

  def get_all_army_info
    medium_cities.inject({}) do |result, medium_city|
      result.merge(medium_city.id.to_s => medium_city.get_army_info)
    end
  end
end
