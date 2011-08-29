require 'spec_helper'

describe CityResource do
  include Rspec::GameDemo::CitySpecHelper
  include Rspec::GameDemo::CityResourceSpecHelper

  fixtures :cities
  fixtures :city_resources

  before(:each) do
    @city = cities(:city_1)
    @city_resource = city_resources(:city_resource_1)
  end

  context "create" do
    it "should set user id" do
      lambda {
        city_resource = @city.city_resource.create(:user_id => 1234)
        city_resource.user.should == @city.user
      }.should change(CityResource, :count).by(1)
    end

    it "should set default values" do
      lambda {
        city_resource = @city.city_resource.build
        city_resource.stub(:collect_tax)
        city_resource.save

        city_resource.food.should == 0
        city_resource.gold.should == 0
        city_resource.population.should == CityResource.default_population
        city_resource.tax_rate.should == CityResource.default_tax_rate
      }.should change(CityResource, :count).by(1)
    end

    it "should not replace by default values" do
      attrs = {:food => 10, :gold => 20, :population => 30, :tax_rate => 0.4}
      lambda {
        city_resource = @city.city_resource.build(attrs)
        city_resource.stub(:collect_tax)
        city_resource.save

        city_resource.food.should == attrs[:food]
        city_resource.gold.should == attrs[:gold]
        city_resource.population.should == attrs[:population]
        city_resource.tax_rate.should == attrs[:tax_rate]
      }.should change(CityResource, :count).by(1)
    end
  end

  it "should update food" do
    @city_resource.stub(:food_output).and_return(1000)
    now = @city_resource.created_at + 20.minutes + 7.seconds

    Timecop.freeze(now) do
      @city_resource.update_food.should == 335
      @city_resource.food.should be_within(0.01).of(335.277777777778)
      @city_resource.food_updated_time.should == now
    end
  end

  context "collect tax" do
    before(:each) do
      update_for_taxation(@city_resource)
      stub_population_increase_and_decrease_config
      @last_taxation_time = @city_resource.last_taxation_time
      @one_hour_later = @last_taxation_time + 1.hours + 5.minutes
    end

    it "should collect tax when create a city" do
      @city.city_resource.create.population.should == 105
    end

    it "less than 1 hour since last taxation" do
      Timecop.freeze(@one_hour_later - 1.hour) { @city_resource.collect_tax }

      @city_resource.gold.should == 300
      @city_resource.population.should == 205
      @city_resource.last_taxation_time.should == @last_taxation_time
    end

    it "more than 2 hours since last taxation" do
      Timecop.freeze(@one_hour_later + 1.hour) { @city_resource.collect_tax }

      @city_resource.gold.should == 192
      @city_resource.population.should == 203
      @city_resource.last_taxation_time.should == @last_taxation_time + 2.hours
    end

    it "should increase population at least by #{CityResource.population_increase_lower_limit}" do
      @city_resource.population = 1
      Timecop.freeze(@one_hour_later) { @city_resource.collect_tax }

      @city_resource.population.should == 2
    end

    it "should increase population at most by #{CityResource.population_increase_upper_limit}" do
      @city_resource.population = 30000
      @city_resource.tax_rate = 40
      Timecop.freeze(@one_hour_later) { @city_resource.collect_tax }

      @city_resource.population.should == 31000
    end

    it "should decrease population at least by #{CityResource.population_decrease_lower_limit}" do
      @city_resource.population = 11
      @city_resource.tax_rate = 0.01
      Timecop.freeze(@one_hour_later) { @city_resource.collect_tax }

      @city_resource.population.should == 10
    end

    it "should decrease population at most by #{CityResource.population_decrease_upper_limit}" do
      @city_resource.should_receive(:adjust_army_training_queues_by_population)

      @city_resource.population = 30000
      Timecop.freeze(@one_hour_later) { @city_resource.collect_tax }

      @city_resource.population.should == 29000
    end
  end

  context "supply food while collecting tax" do
    before(:each) do
      @medium_city_resource = city_resources(:medium_city_resource)
      @medium_city = @medium_city_resource.medium_city
      update_armies_food(@medium_city, 10)
    end

    it "should subtract food for armies" do
      @medium_city_resource.should_receive(:update_food).and_return(100)
      @medium_city_resource.collect_tax

      @medium_city_resource.food.should == 70
      @medium_city.reload
      @medium_city.armies.each {|army| army.food.should == 0}
      @medium_city.armies.each {|army| army.amount.should == 1}
    end

    it "should encounter food crisis" do
      @medium_city_resource.should_receive(:update_food).and_return(20)
      update_armies_amount(@medium_city, 14)
      @medium_city_resource.collect_tax

      @medium_city_resource.food.should == 0
      @medium_city.reload
      @medium_city.armies.each {|army| army.food.should == 0}
      @medium_city.armies.each {|army| army.amount.should == 12}
    end

    it "should decrease at least one of amount" do
      @medium_city_resource.should_receive(:update_food).and_return(20)
      update_armies_amount(@medium_city, 5)
      @medium_city_resource.collect_tax

      @medium_city.reload
      @medium_city.armies.each {|army| army.amount.should == 4}
    end
  end

  context "get resource" do
    before(:each) do
      @city_resource.should_receive(:collect_tax).exactly(1)
    end

    it "should get resource" do
      resource = @city_resource.get_resource
      resource[:food].should_not be_nil
      resource[:gold].should_not be_nil
      resource[:population].should_not be_nil
      resource[:tax_rate].should_not be_nil
    end

    it "should get gold" do
      @city_resource.get_gold.should_not be_nil
    end

    it "should get population" do
      @city_resource.get_population.should_not be_nil
    end
  end

  context "change tax rate" do
    before(:each) do
      @city_resource.should_receive(:collect_tax).exactly(1)
    end

    it "should collect tax first" do
      @city_resource.change_tax_rate(0.3).should == 0.3
      @city_resource.reload
      @city_resource.tax_rate.should == 0.3
    end

    it "should not change tax rate to invalid value" do
      old_tax_rate = @city_resource.tax_rate
      @city_resource.change_tax_rate(-1).should be_false
      @city_resource.reload
      @city_resource.tax_rate.should == old_tax_rate
      @city_resource.errors[:tax_rate].should_not be_empty
    end
  end

  it "food output of capital should be different from normal city's" do
    @city_resource.city.is_capital = true
    normal_city = create_city(@city.user)

    @city_resource.food_output.should_not == normal_city.city_resource.food_output
  end

  it "should adjust army training queues by population" do
    medium_city_resource = city_resources(:medium_city_resource)
    medium_city_resource.medium_city.should_not_receive(:adjust_army_training_queues_by_population)
    medium_city_resource.medium_city.adjust_army_training_queues_by_population
  end
end
