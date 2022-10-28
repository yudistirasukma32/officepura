class AlterTableReceiptreturnAddInvoicereturnId < ActiveRecord::Migration
  def up
  	add_column :receiptreturns, :invoicereturn_id, :int 
  end

  def down
  end
end
