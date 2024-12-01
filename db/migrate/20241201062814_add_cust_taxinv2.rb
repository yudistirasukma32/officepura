class AddCustTaxinv2 < ActiveRecord::Migration
  def up
    add_column :customers, :price_by, :string
    add_column :customers, :is_weightlost, :boolean, :default => false
    add_column :customers, :is_showqty_loaded, :boolean, :default => false
    add_column :customers, :is_showqty_unloaded, :boolean, :default => false
    add_column :customers, :is_rounded, :boolean, :default => false
  end

  def down
    remove_column :customers, :price_by
    remove_column :customers, :is_weightlost
    remove_column :customers, :is_showqty_loaded
    remove_column :customers, :is_showqty_unloaded
    remove_column :customers, :is_rounded
  end
end
