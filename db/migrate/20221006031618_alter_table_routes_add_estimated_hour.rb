class AlterTableRoutesAddEstimatedHour < ActiveRecord::Migration
  def up
    add_column :routes, :estimated_hour, :int
    add_column :routes, :office_id, :int
  end

  # add_index :routes, [:office_id, :office_id]

  def down
    remove_column :routes, :estimated_hour
    remove_column :routes, :office_id
  end
end
