class AlterTableDriverAddVehicleId < ActiveRecord::Migration
  def up
  	add_column :drivers, :vehicle_id, :integer
  end

  def down
  end
end
