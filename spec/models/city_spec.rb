require 'spec_helper'

describe City do
  include Rspec::GameDemo::CitySpecHelper

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

  it "should create city resource" do
    lambda {
      city = create_city(@user)
      city.should_not be_new_record
    }.should change(CityResource, :count).by(1)
  end

  context "change capital" do
    it "should become capital" do
      @city.become_capital.should be_true
      @city.is_capital.should be_true
    end

    it "old capital should change to be normal city" do
      old_capital = create_capital(@user)

      @city.become_capital
      @city.is_capital.should be_true
      old_capital.reload
      old_capital.is_capital.should be_false
    end

    it "should update food before becoming capital" do
      created_at = @city.city_resource.created_at
      now = created_at + 1.hour + 15.minutes + 3.seconds
      Timecop.freeze(now) { @city.become_capital }

      @city.city_resource.last_food_updated_time.should == created_at + 1.hour
    end

    it "should update food before old capital change to be normal city" do
      created_at = @city.city_resource.created_at

      old_capital = create_capital(@user)
      old_capital.city_resource.update_attributes(:food_updated_time => created_at)

      now = created_at + 1.hour + 15.minutes + 3.seconds
      Timecop.freeze(now) { @city.become_capital }

      old_capital.reload
      old_capital.city_resource.last_food_updated_time.should == created_at + 1.hour
    end
  end

  it "should become medium city" do
    medium_city = @city.become_medium_city
    medium_city.should be_instance_of(MediumCity)
    medium_city.city_type.should == MediumCity::CITY_TYPE
  end
end
