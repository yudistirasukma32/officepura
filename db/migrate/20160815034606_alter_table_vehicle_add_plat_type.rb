class AlterTableVehicleAddPlatType < ActiveRecord::Migration
  def up
  	add_column	:vehicles, :plat_type, :string
  end

  def down
  end
end
