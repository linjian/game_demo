require 'spec_helper'

describe User do
  include Rspec::GameDemo::CitySpecHelper

  fixtures :users
  fixtures :city_resources

  before(:each) do
    @user = users(:user_1)
  end

  context "add city" do
    it "should add a city successfully" do
      lambda {
        new_city = @user.add_city(:area_left_value => 100, :area_bottom_value => 0)
        new_city.should_not be_new_record
      }.should change(City, :count).by(1)
    end

    it "should not add a city due to city count > #{User::MAXIMUM_CITY_COUNT}" do
      create_max_cities(@user)

      lambda {
        @user.add_city(:area_left_value => User::MAXIMUM_CITY_COUNT * 100, :area_bottom_value => 0).should be_false
      }.should_not change(City, :count)

      @user.errors[:city].should_not be_blank
    end

    it "should not add a city due to city overlap with another one" do
      lambda {
        @user.add_city(:area_left_value => 20, :area_bottom_value => 20).should be_false
      }.should_not change(City, :count)

      @user.errors[:city].should_not be_blank
    end
  end

  it "should get all current city resources" do
    all_resources = @user.get_all_current_city_resources
    all_resources.should have(2).item
    all_resources[@user.cities.first.id.to_s].should_not be_empty
  end

  it "should get all army info" do
    army_info = @user.get_all_army_info
    army_info.should have(1).item
    army_info[@user.medium_cities.first.id.to_s].should_not be_empty
  end
end
