class AddCoordinateAndNameToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :area_left_value,   :integer, :null => false
    add_column :cities, :area_bottom_value, :integer, :null => false
    add_column :cities, :name,              :string
  end

  def self.down
    remove_column :cities, :area_left_value
    remove_column :cities, :area_bottom_value
    remove_column :cities, :name
  end
end
