require 'spec_helper'

describe City do
  fixtures :cities

  before(:each) do
    @city = cities(:city_1)
    @user = @city.user
  end

  context "check overlap" do
    it "should overlap" do
      lambda {
        city = City.create(:user_id => @user.id, :area_left_value => 130, :area_bottom_value => 140)
        city.errors[:base].should_not be_blank
      }.should_not change(City, :count)
    end

    it "should not overlap" do
      lambda {
        city = City.create(:user_id => @user.id, :area_left_value => 110, :area_bottom_value => 0)
        city.errors[:base].should be_blank
      }.should change(City, :count).by(1)
    end
  end

  context "overlap?" do
    before(:each) do
      @new_city = City.new(:user_id => @user.id)
    end

    it "existing city should not overlap" do
      @city.should_not be_overlap
    end

    it "should overlap if bottom left point is in another city" do
      @new_city.attributes = {:area_left_value => 130, :area_bottom_value => 140}
      @new_city.should be_overlap
    end

    it "should overlap if bottom right point is in another city" do
      @new_city.attributes = {:area_left_value => 30, :area_bottom_value => 140}
      @new_city.should be_overlap
    end

    it "should overlap if top left point is in another city" do
      @new_city.attributes = {:area_left_value => 130, :area_bottom_value => 40}
      @new_city.should be_overlap
    end

    it "should overlap if top right point is in another city" do
      @new_city.attributes = {:area_left_value => 30, :area_bottom_value => 40}
      @new_city.should be_overlap
    end

    it "should not overlap if top right point < another city's bottom" do
      @new_city.attributes = {:area_left_value => 110, :area_bottom_value => 0}
      @new_city.should_not be_overlap
    end

    it "should not overlap if top right point < another city's left" do
      @new_city.attributes = {:area_left_value => 0, :area_bottom_value => 40}
      @new_city.should_not be_overlap
    end

    it "should not overlap if bottom left point > another city's top" do
      @new_city.attributes = {:area_left_value => 90, :area_bottom_value => 200}
      @new_city.should_not be_overlap
    end

    it "should not overlap if bottom left point > another city's right" do
      @new_city.attributes = {:area_left_value => 200, :area_bottom_value => 70}
      @new_city.should_not be_overlap
    end
  end
end
