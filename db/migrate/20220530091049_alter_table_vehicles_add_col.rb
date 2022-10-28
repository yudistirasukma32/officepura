class AlterTableVehiclesAddCol < ActiveRecord::Migration
  def up
    add_column :vehicles, :platform_type, :string, after: :tank_type
  end

  def down
    remove_column :vehicles, :platform_type
  end
end
