class AddFoodRelatedToArmies < ActiveRecord::Migration
  def self.up
    add_column :armies, :food, :float, :null => false, :default => 0
    add_column :armies, :food_updated_time, :datetime
  end

  def self.down
    remove_column :armies, :food
    remove_column :armies, :food_updated_time
  end
end
