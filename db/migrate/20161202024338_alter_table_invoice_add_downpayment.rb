class AlterTableInvoiceAddDownpayment < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :downpayment, :money, :default => 0
  	add_column :taxinvoices, :downpayment_date, :date
  end

  def down
  end
end
