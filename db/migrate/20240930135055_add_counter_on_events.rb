class AddCounterOnEvents < ActiveRecord::Migration
  def up
    add_column :events, :invoice_count, :integer, :default => 0
    add_column :events, :invoiceconfirmed_count, :integer, :default => 0
    add_column :events, :invoice_taxitems_count, :integer, :default => 0
    add_column :events, :invoice_taxinv_count, :integer, :default => 0
  end

  def down
    remove_column :events, :invoice_count
    remove_column :events, :invoiceconfirmed_count
    remove_column :events, :invoice_taxitems_count
    remove_column :events, :invoice_taxinv_count
  end
end