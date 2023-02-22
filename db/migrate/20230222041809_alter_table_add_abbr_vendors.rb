class AlterTableAddAbbrVendors < ActiveRecord::Migration
  def up
    add_column :vendors, :abbr, :string
    add_column :vendors, :category, :string
  end

  def down
    remove_column :vendors, :abbr
    remove_column :vendors, :category
  end
end
