class AlterTableUpdDriverVendor < ActiveRecord::Migration
  def up
    add_column :drivers, :is_resign, :boolean, :default => false
    add_column :drivers, :vendor_id, :int
  end

  def down
    remove_column :drivers, :is_resign
    remove_column :drivers, :vendor_id
  end
end
