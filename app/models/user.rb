class User < ActiveRecord::Base
  has_many :cities, :before_add => :check_cities_count

  def check_cities_count(city)
    raise 'too many cities' if cities.size >= City::MAXIMUM_PER_USER
  end
end
