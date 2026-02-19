class AlterTableAddCoordinateBkk < ActiveRecord::Migration
  def up
    add_column :invoices, :load_longitude, :string
    add_column :invoices, :load_latitude, :string
    add_column :invoices, :unload_longitude, :string
    add_column :invoices, :unload_latitude, :string
  end

  def down
    remove_column :invoices, :load_longitude
    remove_column :invoices, :load_latitude 
    remove_column :invoices, :unload_longitude
    remove_column :invoices, :unload_latitude 
  end
end