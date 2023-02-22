class AlterTableContainermemos < ActiveRecord::Migration
  def up
    add_column :containermemos, :vendor_id, :int
    add_column :containermemos, :price_per, :money, :default => 0

    add_column :containerexpenses, :containermemo_id, :int
  end

  def down
    remove_column :containermemos, :vendor_id
    remove_column :containermemos, :price_per

    remove_column :containerexpenses, :containermemo_id
  end
end
