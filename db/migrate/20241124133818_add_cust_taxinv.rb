class AddCustTaxinv < ActiveRecord::Migration
  def up
    add_column :customers, :province, :string
    add_column :customers, :gst_percentage, :int, :default => 0
    add_column :customers, :price_tax, :boolean, :default => false
    add_column :customers, :rating, :int, :default => 0
  end

  def down
    remove_column :customers, :province
    remove_column :customers, :gst_percentage
    remove_column :customers, :price_tax
    remove_column :customers, :rating
  end
end