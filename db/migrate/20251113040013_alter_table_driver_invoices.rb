class AlterTableDriverInvoices < ActiveRecord::Migration
  def up
    add_column :drivers, :email, :string
    add_column :drivers, :app_version, :string
    add_column :drivers, :device_type, :string
    
    add_column :invoices, :app_status, :string
  end

  def down
    remove_column :drivers, :email 
    remove_column :drivers, :app_version 
    remove_column :drivers, :device_type

    remove_column :invoices, :app_status 
  end
end
