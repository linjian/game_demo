require 'spec_helper'

describe Army do
  fixtures :armies

  before(:each) do
    @spearman = armies(:spearman).specialize
    @archer = armies(:archer).specialize
    @cavalry = armies(:cavalry).specialize
  end

  it "should belongs to a medium city" do
    @spearman.medium_city.should_not be_nil
  end

  context "specialize" do
    it "should be spearman" do
      @spearman.should be_instance_of(Army::Spearman)
    end

    it "should be archer" do
      @archer.specialize.should be_instance_of(Army::Archer)
    end

    it "should be cavalry" do
      @cavalry.specialize.should be_instance_of(Army::Cavalry)
    end
  end

  context "gold cost" do
    it "spearman" do
      Army::Spearman.gold_cost.should_not be_nil
    end

    it "archer" do
      Army::Archer.gold_cost.should_not be_nil
    end

    it "cavalry" do
      Army::Cavalry.gold_cost.should_not be_nil
    end
  end

  context "training duration" do
    it "spearman" do
      Army::Spearman.training_duration.should_not be_nil
    end

    it "archer" do
      Army::Archer.training_duration.should_not be_nil
    end

    it "cavalry" do
      Army::Cavalry.training_duration.should_not be_nil
    end
  end

  context "food consumption" do
    it "spearman" do
      Army::Spearman.food_consumption.should_not be_nil
    end

    it "archer" do
      Army::Archer.food_consumption.should_not be_nil
    end

    it "cavalry" do
      Army::Cavalry.food_consumption.should_not be_nil
    end
  end

  context "set food" do
    before(:each) do
      Army::Spearman.stub(:food_consumption).and_return(10)
      @spearman.update_attribute(:food, 1.5)
      @spearman.update_attribute(:food_updated_time, Time.now.utc)
      @now = @spearman.food_updated_time + 10.minutes
    end

    it "should set food if amount is changed" do
      Timecop.freeze(@now) do
        @spearman.update_attributes(:amount => 5)
      end

      @spearman.food.should be_within(0.01).of(3.16666666666667)
      @spearman.food_updated_time.should == @now
    end

    it "should not set food if amount is not changed" do
      @spearman.update_attributes(:updated_at => @now)
      @spearman.food.should == 1.5
      @spearman.food_updated_time.should == @now - 10.minutes
    end

    it "should set food when create" do
      Timecop.freeze(@now) do
        archer = Army::Archer.create(:amount => 5, :user_id => 1, :city_id => 1)
        archer.food.should == 0
        archer.food_updated_time.should == @now
      end
    end
  end

  it "should get food" do
    @spearman.stub(:calculate_food).and_return(21.345)
    @spearman.get_food.should == 21
  end

  it "should set army_type when create" do
    cavalry = Army::Cavalry.create(:amount => 4, :user_id => 1, :city_id => 1)
    cavalry.army_type.should == Army::Cavalry::ARMY_TYPE
  end
end
