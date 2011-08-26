module Rspec
  module GameDemo
    module CityHelper
      def create_max_cities(user)
        (User::MAXIMUM_CITY_COUNT - user.cities.size).times do |i|
          user.cities.create(:area_left_value => i * City::SIDE_LENGTH, :area_bottom_value => 0)
        end
      end
    end
  end
end
