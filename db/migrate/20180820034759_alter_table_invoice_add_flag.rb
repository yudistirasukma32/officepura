class AlterTableInvoiceAddFlag < ActiveRecord::Migration
  def up
	  	add_column :invoices, :invoicetrain, :boolean, :default => false
  end

  def down
  end
end
