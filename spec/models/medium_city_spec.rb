require 'spec_helper'

describe MediumCity do
  include Rspec::GameDemo::ArmyTrainingQueueSpecHelper

  fixtures :cities
  fixtures :army_training_queues

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

  context "add army training queue" do
    before(:each) do
      @queue_attrs = {:army_type => Army::Spearman::ARMY_TYPE, :amount => 5}
    end

    it "should add a queue successfully" do
      lambda {
        queue = @medium_city.add_army_training_queue(@queue_attrs)
        queue.user.should == @medium_city.user
      }.should change(ArmyTrainingQueue, :count).by(1)
    end

    it "should not add a queue if queue count > #{MediumCity::MAXIMUM_WAITING_TRAINING_QUEUE}" do
      create_max_waiting_queues(@medium_city)

      lambda {
        @medium_city.add_army_training_queue(@queue_attrs).should be_false
      }.should_not change(ArmyTrainingQueue, :count)

      @medium_city.errors[:army_training_queue].should_not be_blank
    end

    it "should not add a queue if not enough population" do
      lambda {
        @medium_city.add_army_training_queue(@queue_attrs.merge(:amount => 1000)).should be_false
      }.should_not change(ArmyTrainingQueue, :count)

      @medium_city.errors[:army_training_queue].should_not be_blank
    end
  end

  context "cancel army training queue" do
    before(:each) do
      @queue = create_training_queue(@medium_city)
    end

    it "should cancel a queue successfully" do
      lambda {
        @medium_city.cancel_army_training_queue(@queue).should be_true
      }.should change(ArmyTrainingQueue, :count).by(-1)
    end

    it "should not cancel a in training queue" do
      @queue.update_attributes(:in_training => true)

      lambda {
        @medium_city.cancel_army_training_queue(@queue).should be_false
      }.should_not change(ArmyTrainingQueue, :count)

      @medium_city.errors[:army_training_queue].should_not be_blank
    end
  end
end
