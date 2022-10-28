class AlterTableVehicle < ActiveRecord::Migration
  def up
  	add_column :vehicles, :date_purchase, :date
  	add_column :vehicles, :amount, :money, :default => 0
  end

  def down
  end
end
