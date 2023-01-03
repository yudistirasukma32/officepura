class AlterTableInvAddDuplicateNopol < ActiveRecord::Migration
  def up
    add_column :invoices, :vehicle_duplicate, :string
    add_column :invoices, :vehicle_duplicate_id, :int
  end

  def down
    remove_column :invoices, :vehicle_duplicate
    remove_column :invoices, :vehicle_duplicate_id
  end
end
