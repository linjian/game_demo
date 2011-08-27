require 'spec_helper'

describe CityResource do
  fixtures :cities

  before(:each) do
    @city = cities(:city_1)
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
end
