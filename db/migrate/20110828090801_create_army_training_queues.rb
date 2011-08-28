class CreateArmyTrainingQueues < ActiveRecord::Migration
  def self.up
    create_table :army_training_queues do |t|
      t.integer  :city_id,              :null => false
      t.integer  :user_id,              :null => false
      t.string   :army_type,            :null => false
      t.integer  :amount,               :null => false, :default => 0
      t.boolean  :in_training,          :null => false, :default => false
      t.datetime :start_training_time

      t.timestamps
    end
  end

  def self.down
    drop_table :army_training_queues
  end
end
