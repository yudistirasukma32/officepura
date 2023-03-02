class AlterTableUpdVendorAddUser < ActiveRecord::Migration
  def up
    add_column :vendors, :created_by, :int
  end

  def down
    remove_column :vendors, :created_by
  end
end
