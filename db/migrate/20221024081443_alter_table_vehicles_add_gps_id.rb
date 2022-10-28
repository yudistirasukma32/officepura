class AlterTableVehiclesAddGpsId < ActiveRecord::Migration
  def up
    add_column :vehicles, :gps_number, :int
  end

  def down
    remove_column :vehicles, :gps_number
  end
end
