class AlterTableReceiptsAddUserId < ActiveRecord::Migration
  def up
  	add_column :receipts, :user_id, :int
  	add_column :receiptreturns, :user_id, :int
  	add_column :receiptexpenses, :user_id, :int
  	add_column :receiptpremis, :user_id, :int
  	add_column :receiptorders, :user_id, :int
  end

  def down
  	remove_column :receipts, :user_id
  	remove_column :receiptreturns, :user_id
  	remove_column :receiptexpenses, :user_id
  	remove_column :receiptpremis, :user_id
  	remove_column :receiptorders, :user_id
  end
end
