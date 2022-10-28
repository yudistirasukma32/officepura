class AlterTableEventRemoveVendor < ActiveRecord::Migration
  def up
    remove_column :events, :vendor_sby
    remove_column :events, :vendor_smg
    remove_column :events, :vendor_jkt
    remove_column :events, :vendor_smt
    remove_column :events, :vendor_lorry
  end

  def down
  end
end
