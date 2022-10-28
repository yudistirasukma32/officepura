class AlterTableInvoicesHelperAllowances < ActiveRecord::Migration
  def up
  	add_column :invoices, :helper_allowance, :money, :default => 0
  	add_column :invoices, :need_helper, :boolean, :default => false
  	add_column :invoicereturns, :helper_allowance, :money, :default => 0
  	add_column :receipts, :helper_allowance, :money, :default => 0
  	add_column :receiptreturns, :helper_allowance, :money, :default => 0
    add_column :allowances, :helper_trip, :money, :default => 0
  end

  def down
  	remove_column :invoices, :helper_allowance
  	remove_column :invoicereturns, :helper_allowance
  	remove_column :receipts, :helper_allowance
  	remove_column :receiptreturns, :helper_allowance
  end
end
