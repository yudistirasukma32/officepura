class AlterTableVehicleAddTireTarget < ActiveRecord::Migration
  def up
  	add_column :vehicles, :tire_target, :integer, :default => 0
  end

  def down
  end
end
