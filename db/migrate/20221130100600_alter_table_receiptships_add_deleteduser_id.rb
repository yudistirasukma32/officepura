class AlterTableReceiptshipsAddDeleteduserId < ActiveRecord::Migration
  def up
    add_column :receiptships, :deleteuser_id, :int
  end

  def down
    remove_column :receiptships, :deleteuser_id
  end
end
