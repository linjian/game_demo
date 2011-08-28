class AddCapital < ActiveRecord::Migration
  def self.up
    add_column :cities, :is_capital, :boolean
  end

  def self.down
    remove_column :cities, :is_capital
  end
end
