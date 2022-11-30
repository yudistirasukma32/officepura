class AlterTableReceiptships < ActiveRecord::Migration
  def up
    add_column :receiptships, :office_id, :int
    remove_column :receiptships, :date
  end

  def down
    remove_column :receiptships, :office_id
  end
end
