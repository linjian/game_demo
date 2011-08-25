require 'spec_helper'

describe City do
  fixtures :cities

  before :each do
    @city = cities(:city1)
  end

  it "should belongs to user" do
    @city.user.should_not be_nil
  end
end
