module Rspec
  module GameDemo
    module CitySpecHelper
      def create_max_cities(user)
        (User.maximum_city_count - user.cities.size).times do |i|
          user.cities.create(:area_left_value => i * City.city_side_length, :area_bottom_value => 0)
        end
      end

      def create_city(user)
        City.create(:user_id => user.id, :area_left_value => 110, :area_bottom_value => 0)
      end

      def create_capital(user)
        capital = create_city(user)
        capital.update_attributes(:is_capital => true)
        capital
      end

      def update_armies_food(city, food)
        city.armies.each {|army| army.update_attribute(:food, food)}
      end

      def update_armies_amount(city, amount)
        city.armies.each {|army| army.update_attribute(:amount, amount)}
      end
    end
  end
end
