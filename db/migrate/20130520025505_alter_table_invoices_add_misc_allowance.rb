class AlterTableInvoicesAddMiscAllowance < ActiveRecord::Migration
  def up
  	add_column :allowances, :misc_allowance, :money, :default => 0
  	add_column :invoices, :misc_allowance, :money, :default => 0
    add_column :invoicereturns, :misc_allowance, :money, :default => 0
  	add_column :receipts, :misc_allowance, :money, :default => 0
    add_column :receiptreturns, :misc_allowance, :money, :default => 0
  	add_column :receipts, :ferry_fee, :money, :default => 0
	  add_column :receipts, :tol_fee, :money, :default => 0
  end

  def down
  	remove_column :allowances, :misc_allowance
  	remove_column :invoices, :misc_allowance
    remove_column :invoicereturns, :misc_allowance
  	remove_column :receipts, :misc_allowance
    remove_column :receiptreturns, :misc_allowance
  	remove_column :receipts, :ferry_fee
  	remove_column :receipts, :tol_fee
  end
end
