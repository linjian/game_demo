require 'spec_helper'

describe ArmyTrainingQueue do
  include Rspec::GameDemo::ArmyTrainingQueueSpecHelper

  fixtures :cities
  fixtures :army_training_queues

  before(:each) do
    @medium_city = cities(:medium_city).become_medium_city
    @in_training_queue = create_in_training_queue(@medium_city)
    @start_training_time = @in_training_queue.start_training_time
    @now = @start_training_time + 1.minutes
  end

  it "should get training spent time" do
    Timecop.freeze(@now) do
      @in_training_queue.training_spent_time.should == 1.minutes
    end
  end

  it "should get training remain time" do
    Timecop.freeze(@now) do
      @in_training_queue.training_remain_time.should == Army::Spearman::TRAINING_DURATION - 1.minutes
    end
  end

  it "should not get training spent time for waiting queue" do
    waiting_queue = create_waiting_queue(@medium_city)
    waiting_queue.training_spent_time.should be_nil
  end

  it "should not get training remain time for waiting queue" do
    waiting_queue = create_waiting_queue(@medium_city)
    waiting_queue.training_remain_time.should be_nil
  end
end
