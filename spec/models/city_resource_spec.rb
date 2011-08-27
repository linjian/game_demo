require 'spec_helper'

describe CityResource do
  include Rspec::GameDemo::CityResourceSpecHelper

  fixtures :cities
  fixtures :city_resources

  before(:each) do
    @city = cities(:city_1)
    @city_resource = city_resources(:city_resource_1)
  end

  context "create" do
    it "should set user id" do
      lambda {
        city_resource = @city.city_resource.create(:user_id => 1234)
        city_resource.user.should == @city.user
      }.should change(CityResource, :count).by(1)
    end

    it "should set default values" do
      lambda {
        city_resource = @city.city_resource.create

        city_resource.food.should == 0
        city_resource.gold.should == 0
        city_resource.population.should == CityResource::DEFAULT_POPULATION
        city_resource.tax_rate.should == CityResource::DEFAULT_TAX_RATE
      }.should change(CityResource, :count).by(1)
    end

    it "should not replace by default values" do
      attrs = {:food => 10, :gold => 20, :population => 30, :tax_rate => 40}
      lambda {
        city_resource = @city.city_resource.create(attrs)

        city_resource.food.should == attrs[:food]
        city_resource.gold.should == attrs[:gold]
        city_resource.population.should == attrs[:population]
        city_resource.tax_rate.should == attrs[:tax_rate]
      }.should change(CityResource, :count).by(1)
    end
  end

  context "get food" do
    before(:each) do
      @created_at = @city_resource.created_at
      CityResource.stub!(:food_output).and_return(1000)
    end

    it "food_updated_time is nil and less than 1 hour since city created" do
      now = @created_at + 20.minutes + 7.seconds

      Timecop.freeze(now) do
        @city_resource.get_food.should == 335
        @city_resource.food.should == 0
        @city_resource.food_updated_time.should be_nil
      end
    end

    it "food_updated_time is nil and more than 1 hour since city created" do
      now = @created_at + 1.hour + 15.minutes + 3.seconds

      Timecop.freeze(now) do
        @city_resource.get_food.should == 1250
        @city_resource.food.should == 1000
        @city_resource.food_updated_time.should == @created_at + 1.hour
      end
    end

    it "food_updated_time exists and less than 1 hour since last update" do
      update_food(@city_resource, 1)
      now = @created_at + 1.hour + 25.minutes + 5.seconds

      Timecop.freeze(now) do
        @city_resource.get_food.should == 1418
        @city_resource.food.should == 1000
        @city_resource.food_updated_time.should == @created_at + 1.hour
      end
    end

    it "food_updated_time exists and more than 2 hours since last update" do
      update_food(@city_resource, 1)
      now = @created_at + 3.hours + 28.minutes + 9.seconds

      Timecop.freeze(now) do
        @city_resource.get_food.should == 3469
        @city_resource.food.should == 3000
        @city_resource.food_updated_time.should == @created_at + 3.hours
      end
    end
  end
end
