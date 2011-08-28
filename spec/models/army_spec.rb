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
end
