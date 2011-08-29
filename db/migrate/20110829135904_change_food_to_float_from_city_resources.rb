class ChangeFoodToFloatFromCityResources < ActiveRecord::Migration
  def self.up
    change_column :city_resources, :food, :float, :null => false, :default => 0
  end

  def self.down
    change_column :city_resources, :food, :integer, :null => false, :default => 0
  end
end
