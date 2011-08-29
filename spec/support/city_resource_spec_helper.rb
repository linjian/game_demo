module Rspec
  module GameDemo
    module CityResourceSpecHelper
      def update_for_taxation(city_resource)
        city_resource.update_attributes(
          :last_taxation_time => city_resource.created_at + 3.hours,
          :gold               => 300,
          :population         => 205)
      end

      def stub_population_increase_and_decrease_config
        CityResource.stub!(:population_increase_lower_limit).and_return(1)
        CityResource.stub!(:population_decrease_lower_limit).and_return(1)
        CityResource.stub!(:population_increase_upper_limit).and_return(1000)
        CityResource.stub!(:population_decrease_upper_limit).and_return(1000)
        CityResource.stub!(:population_increase_rate).and_return(5)
        CityResource.stub!(:population_decrease_rate).and_return(5)
      end
    end
  end
end
