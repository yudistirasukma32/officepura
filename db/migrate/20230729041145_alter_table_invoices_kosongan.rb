class AlterTableInvoicesKosongan < ActiveRecord::Migration
  def up
    add_column :invoices, :kosongan, :boolean, :default => false
    add_column :invoices, :kosongan_type, :string
    add_column :invoices, :kosongan_confirmed, :boolean, :default => false
    add_column :invoices, :kosongan_confirmed_by, :int
    add_column :invoices, :kosongan_previous_invoice_id, :int
  end

  def down
    remove_column :invoices, :kosongan
    remove_column :invoices, :kosongan_type
    remove_column :invoices, :kosongan_confirmed
    remove_column :invoices, :kosongan_confirmed_by
    remove_column :invoices, :kosongan_previous_invoice_id
  end
end
