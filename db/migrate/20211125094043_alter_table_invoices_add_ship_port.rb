class AlterTableInvoicesAddShipPort < ActiveRecord::Migration
  def up
    add_column :invoices, :port_id, :int
    add_column :invoices, :ship_id, :int
    add_column :invoices, :train_fee, :money, :default => 0 rescue nil
  end

  def down
    remove_column :invoices, :port_id
    remove_column :invoices, :ship_id
    remove_column :invoices, :train_fee
  end
end
