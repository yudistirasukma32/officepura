class AlterTableInvoicesAddMultimoda < ActiveRecord::Migration
  def up
    add_column :invoices, :shipoperator_id, :int
    add_column :invoices, :routeship_id, :int
    add_column :invoices, :invoicemultimode, :boolean, :default => false
  end

  def down
    remove_column :invoices, :shipoperator_id
    remove_column :invoices, :routeship_id
    remove_column :invoices, :invoicemultimode
  end
end
