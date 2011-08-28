require 'spec_helper'

describe MediumCity do
  fixtures :cities

  before(:each) do
    @medium_city = cities(:medium_city).become_medium_city
  end

  context "has armies" do
    it "should has one spearman" do
      @medium_city.spearman.army_type.should == Army::Spearman::ARMY_TYPE
    end

    it "should has one archer" do
      @medium_city.archer.army_type.should == Army::Archer::ARMY_TYPE
    end

    it "should has one cavalry" do
      @medium_city.cavalry.army_type.should == Army::Cavalry::ARMY_TYPE
    end
  end
end
