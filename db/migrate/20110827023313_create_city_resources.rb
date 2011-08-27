class CreateCityResources < ActiveRecord::Migration
  def self.up
    create_table :city_resources do |t|
      t.integer   :city_id,             :null => false
      t.integer   :user_id,             :null => false
      t.integer   :food,                :null => false, :default => 0
      t.integer   :gold,                :null => false, :default => 0
      t.integer   :population,          :null => false, :default => 100
      t.integer   :tax_rate,            :null => false, :default => 20
      t.datetime  :last_taxation_time
      t.datetime  :food_updated_time

      t.timestamps
    end
  end

  def self.down
    drop_table :city_resources
  end
end
