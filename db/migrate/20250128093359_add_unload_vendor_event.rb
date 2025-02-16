class AddUnloadVendorEvent < ActiveRecord::Migration
  def up
    add_column :events, :unload_vendor, :boolean, :default => false
  end

  def down
    remove_column :events, :unload_vendor
  end
end
