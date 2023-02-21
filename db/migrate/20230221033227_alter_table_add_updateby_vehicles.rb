class AlterTableAddUpdatebyVehicles < ActiveRecord::Migration
  def up
    add_column :vehicles, :user_id, :int
    add_column :vehicles, :updated_by, :string
    add_column :vehicles, :previous_data, :string
  end

  def down
    remove_column :vehicles, :user_id
    remove_column :vehicles, :updated_by
    remove_column :vehicles, :previous_data
  end
end
