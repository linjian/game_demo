class ChangeLoginFromUsers < ActiveRecord::Migration
  def self.up
    change_column_null :users, :login,    false
    change_column_null :users, :password, false
  end

  def self.down
    change_column_null :users, :login,    true
    change_column_null :users, :password, true
  end
end
