class AlterTableAddDeleteuserid < ActiveRecord::Migration
  def up
  	add_column :invoices, :deleteuser_id, :int
  	add_column :invoicereturns, :deleteuser_id, :int
  	add_column :bonusreceipts, :deleteuser_id, :int
  	add_column :productorders, :deleteuser_id, :int
  	add_column :sales, :deleteuser_id, :int
  	add_column :officeexpenses, :deleteuser_id, :int
  	add_column :receipts, :deleteuser_id, :int
  	add_column :receiptreturns, :deleteuser_id, :int
  	add_column :receiptpremis, :deleteuser_id, :int
  	add_column :receiptorders, :deleteuser_id, :int
  	add_column :receiptsales, :deleteuser_id, :int
  	add_column :receiptexpenses, :deleteuser_id, :int
  end

  def down
  	remove_column :invoicereturns, :deleteuser_id
  	remove_column :bonusreceipts, :deleteuser_id 
  	remove_column :productorders, :deleteuser_id 
  	remove_column :sales, :deleteuser_id 
  	remove_column :receipts, :deleteuser_id 
  	remove_column :receiptreturns, :deleteuser_id 
  	remove_column :receiptpremis, :deleteuser_id 
  	remove_column :receiptorders, :deleteuser_id 
  	remove_column :receiptsales, :deleteuser_id
  end
end
