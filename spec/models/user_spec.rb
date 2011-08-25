require 'spec_helper'

describe User do
  fixtures :users

  before :each do
    @user = users(:user1)
  end

  context "has many cities" do
    it "should have at most #{City::MAXIMUM_PER_USER} cities" do
      (City::MAXIMUM_PER_USER - 1).times do
        @user.cities.create
      end

      lambda {
        @user.cities.create
      }.should raise_error

      @user.cities.should have(City::MAXIMUM_PER_USER).records
    end

    it "should destroy cities if user has been destroyed" do
      city_size = @user.cities.size
      lambda {
        @user.destroy
      }.should change(City, :count).by(-city_size)
    end
  end
end
