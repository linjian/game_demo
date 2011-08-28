class AddCityTypeToCities < ActiveRecord::Migration
  def self.up
    add_column :cities, :city_type, :string
  end

  def self.down
    add_column :cities, :city_type
  end
end
