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
      @queue = create_waiting_queue(@medium_city)
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

  context "get army info" do
    it "should get army info" do
      create_in_training_queue(@medium_city)
      @medium_city.should_receive(:do_training)

      army_info = @medium_city.get_army_info
      army_info[:trained_army].should have(3).items
      army_info[:in_training].should_not be_empty
      army_info[:waiting_training].should have(1).items
    end

    it "should get trained army info" do
      trained_army_info = @medium_city.trained_army_info
      trained_army_info[:spearman].should_not be_nil
      trained_army_info[:archer].should_not be_nil
      trained_army_info[:cavalry].should_not be_nil
    end

    it "no trained army" do
      [:spearman, :archer, :cavalry].each {|army| @medium_city.stub(army)}

      trained_army_info = @medium_city.trained_army_info
      trained_army_info[:spearman].should == 0
      trained_army_info[:archer].should == 0
      trained_army_info[:cavalry].should == 0
    end

    it "should get in training info" do
      create_in_training_queue(@medium_city)

      in_training_info = @medium_city.in_training_info
      in_training_info[:army_type].should_not be_nil
      in_training_info[:amount].should_not be_nil
      in_training_info[:start_training_time].should_not be_nil
      in_training_info[:training_spent_time].should_not be_nil
      in_training_info[:training_remain_time].should_not be_nil
    end

    it "no in training info" do
      @medium_city.in_training_info.should be_nil
    end

    it "should get waiting training info" do
      waiting_training_info = @medium_city.waiting_training_info
      waiting_training_info.should have(1).item
      waiting_training_info.first[:army_type].should_not be_nil
      waiting_training_info.first[:amount].should_not be_nil
    end

    it "no waiting training info" do
      clean_waiting_queuqs(@medium_city)
      @medium_city.reload

      @medium_city.waiting_training_info.should be_empty
    end
  end

  context "do training" do
    before(:each) do
      clean_waiting_queuqs(@medium_city)
    end

    it "no queue is waiting for training" do
      lambda {
        @medium_city.do_training
      }.should_not change(ArmyTrainingQueue, :count)
    end

    context "one queue" do
      it "one queue will be in training" do
        waiting_queue = create_waiting_queue(@medium_city)
        old_population = @medium_city.city_resource.population

        @medium_city.do_training
        waiting_queue.should be_in_training
        waiting_queue.start_training_time.should_not be_nil

        @medium_city.city_resource.reload
        @medium_city.city_resource.population.should == old_population - waiting_queue.amount
      end

      it "one queue is in training" do
        create_in_training_queue(@medium_city)

        lambda {
          @medium_city.do_training
        }.should_not change(ArmyTrainingQueue, :count)
      end

      it "one queue is finished training and no more queue" do
        in_training_queue = create_in_training_queue(@medium_city)
        now = in_training_queue.start_training_time + 100.hours
        old_amount = @medium_city.spearman.amount
        @medium_city.city_resource.update_attributes(:gold => 20)

        Timecop.freeze(now) do
          lambda {
            @medium_city.do_training
          }.should change(ArmyTrainingQueue, :count).by(-1)
        end

        @medium_city.reload
        @medium_city.spearman.amount.should == old_amount + in_training_queue.amount
        @medium_city.city_resource.gold.should == 15
      end
    end

    context "two queues" do
      before(:each) do
        @in_training_queue = create_in_training_queue(@medium_city)
        @waiting_queue = create_waiting_queue(@medium_city)
      end

      it "one queue is in training and one more queue" do
        lambda {
          @medium_city.do_training
        }.should_not change(ArmyTrainingQueue, :count)
      end

      it "one queue is finished training and one more queue will be in training" do
        now = @in_training_queue.start_training_time + 20.minutes
        Timecop.freeze(now) do
          lambda {
            @medium_city.do_training
          }.should change(ArmyTrainingQueue, :count).by(-1)
        end

        @waiting_queue.should be_in_training
      end

      it "two queues are all finished training" do
        now = @in_training_queue.start_training_time + 100.hours
        Timecop.freeze(now) do
          lambda {
            @medium_city.do_training
          }.should change(ArmyTrainingQueue, :count).by(-2)
        end
      end
    end

    context "three queues" do
      before(:each) do
        @in_training_queue = create_in_training_queue(@medium_city)
        @waiting_queue_1 = create_waiting_queue(@medium_city)
        @waiting_queue_2 = create_waiting_queue(@medium_city)
      end

      it "one queue is finished training and two more queues will be in training" do
        now = @in_training_queue.start_training_time + 19.minutes
        Timecop.freeze(now) do
          lambda {
            @medium_city.do_training
          }.should change(ArmyTrainingQueue, :count).by(-1)
        end

        @waiting_queue_1.should be_in_training
        @waiting_queue_2.should_not be_in_training
      end

      it "two queues are all finished training and one more queues will be in training" do
        now = @in_training_queue.start_training_time + 37.minutes
        Timecop.freeze(now) do
          lambda {
            @medium_city.do_training
          }.should change(ArmyTrainingQueue, :count).by(-2)
        end

        @waiting_queue_2.should be_in_training
      end
    end

    it "should create army if not exists" do
      @medium_city.spearman.destroy
      in_training_queue = create_in_training_queue(@medium_city)
      now = in_training_queue.start_training_time + 100.hours

      Timecop.freeze(now) do
        lambda {
          @medium_city.do_training
        }.should change(ArmyTrainingQueue, :count).by(-1)
      end

      @medium_city.reload
      @medium_city.spearman.should be
    end
  end

  context "adjust army training queues by population" do
    before(:each) do
      2.times { create_waiting_queue(@medium_city) }
    end

    it "should decrease amount of last queue" do
      @medium_city.city_resource.update_attributes(:population => 8)
      @medium_city.adjust_army_training_queues_by_population

      @medium_city.reload
      @medium_city.waiting_training_queues.last.amount.should == 2
    end

    it "should destroy last queue and decrease amount of second last queue" do
      @medium_city.city_resource.update_attributes(:population => 5)

      lambda {
        @medium_city.adjust_army_training_queues_by_population
      }.should change(ArmyTrainingQueue, :count).by(-1)

      @medium_city.reload
      @medium_city.waiting_training_queues.last.amount.should == 4
    end

    it "should decrease all waiting queues" do
      @medium_city.city_resource.update_attributes(:population => 0)

      lambda {
        @medium_city.adjust_army_training_queues_by_population
      }.should change(ArmyTrainingQueue, :count).by(-3)
    end
  end
end
