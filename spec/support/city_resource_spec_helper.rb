module Rspec
  module GameDemo
    module CityResourceSpecHelper
      def update_food(city_resource, hours)
        city_resource.update_attributes(
          :food_updated_time => city_resource.created_at + hours.hours,
          :food => hours * 1000) if hours > 0
      end
    end
  end
end
