class ChangeUserIdFromCities < ActiveRecord::Migration
  def self.up
    change_column_null :cities, :user_id, false
  end

  def self.down
    change_column_null :cities, :user_id, true
  end
end
