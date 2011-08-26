require 'spec_helper'

describe User do
  include Rspec::GameDemo::CityHelper

  fixtures :users

  before(:each) do
    @user = users(:user_1)
  end

  context "add city" do
    it "should add a city successfully" do
      lambda {
        @user.add_city(:area_left_value => 100, :area_bottom_value => 0).should be_true
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
end
