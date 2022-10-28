class AlterTableInvoicesAddPremi < ActiveRecord::Migration
  def up
    add_column :invoices, :premi, :boolean, :default => false
    add_column :invoices, :premi_allowance, :money, :default => 0
    add_column :receipts, :premi_allowance, :money, :default => 0
    add_column :invoicereturns, :premi_allowance, :money, :default => 0
    add_column :receiptreturns, :premi_allowance, :money, :default => 0
  end

  def down
    remove_column :invoices, :premi
    remove_column :invoices, :premi_allowance
    remove_column :receipts, :premi_allowance
    remove_column :invoicereturns, :premi_allowance
    remove_column :receiptreturns, :premi_allowance
  end
end