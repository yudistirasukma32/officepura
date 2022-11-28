class AlterTableAddGstTrainexpense < ActiveRecord::Migration
  def up
    add_column :trainexpenses, :gst_percentage, :int, :default => 0
    add_column :trainexpenses, :gst_tax, :money, :default => 0
    add_column :trainexpenses, :price_per, :money, :default => 0

    add_column :receipttrains, :gst_percentage, :int, :default => 0
    add_column :receipttrains, :gst_tax, :money, :default => 0

    add_column :shipexpenses, :gst_percentage, :int, :default => 0
    add_column :shipexpenses, :gst_tax, :money, :default => 0
    add_column :shipexpenses, :price_per, :money, :default => 0

    add_column :receiptships, :gst_percentage, :int, :default => 0
    add_column :receiptships, :gst_tax, :money, :default => 0
  end

  def down
    remove_column :trainexpenses, :gst_percentage
    remove_column :trainexpenses, :gst_tax

    remove_column :receipttrains, :gst_percentage
    remove_column :receipttrains, :gst_tax

    remove_column :shipexpenses, :gst_percentage
    remove_column :shipexpenses, :gst_tax

    remove_column :receiptships, :gst_percentage
    remove_column :receiptships, :gst_tax
  end
end
