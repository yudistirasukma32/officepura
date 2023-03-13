class AlterTableInvComplByVendor < ActiveRecord::Migration
  def up
    add_column :invoices, :by_vendor, :boolean, :default => false
    add_column :invoices, :truckvendor_id, :int
  end

  def down
    remove_column :invoices, :by_vendor
    remove_column :invoices, :truckvendor_id
  end
end
