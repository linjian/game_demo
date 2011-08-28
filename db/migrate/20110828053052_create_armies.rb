class CreateArmies < ActiveRecord::Migration
  def self.up
    create_table :armies do |t|
      t.integer :city_id,   :null => false
      t.integer :user_id,   :null => false
      t.string  :army_type, :null => false
      t.integer :amount,    :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :armies
  end
end
