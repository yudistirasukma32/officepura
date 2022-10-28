class AlterTableVehicleAddTanktype < ActiveRecord::Migration
  def up
  	add_column :vehicles, :tank_type, :string
  end

  def down
  	remove_column :vehicles, :tank_type
  end
end
