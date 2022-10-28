class AlterTableAddUserIdBkk < ActiveRecord::Migration
  def up
  	add_column :invoices, :user_id, :int
  	add_column :invoicereturns, :user_id, :int
  	add_column :bonusreceipts, :user_id, :int
  	add_column :productorders, :user_id, :int
  end

  def down
  end
end
