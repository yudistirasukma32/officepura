class AlterTableContainerexpenses < ActiveRecord::Migration
  def up
    add_column :containerexpenses, :gst_percentage, :int, :default => 0
    add_column :containerexpenses, :gst_tax, :money, :default => 0
    add_column :containerexpenses, :price_per, :money, :default => 0

    add_column :receiptcontainers, :gst_percentage, :int, :default => 0
    add_column :receiptcontainers, :gst_tax, :money, :default => 0

  end

  def down
    remove_column :containerexpenses, :gst_percentage
    remove_column :containerexpenses, :gst_tax

    remove_column :receiptcontainers, :gst_percentage
    remove_column :receiptcontainers, :gst_tax
  end
end
