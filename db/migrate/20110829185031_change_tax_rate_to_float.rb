class ChangeTaxRateToFloat < ActiveRecord::Migration
  def self.up
    change_column :city_resources, :tax_rate, :float, :null => false, :default => 0.2
  end

  def self.down
    change_column :city_resources, :tax_rate, :integer, :null => false, :default => 20
  end
end
