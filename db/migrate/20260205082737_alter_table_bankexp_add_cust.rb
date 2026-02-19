class AlterTableBankexpAddCust < ActiveRecord::Migration
  def up
    add_column :bankexpenses, :customer_id, :int
  end

  def down
    remove_column :bankexpenses, :customer_id
  end
end
