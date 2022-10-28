class AlterTableInvoiceAddIsotank < ActiveRecord::Migration
  def up
  	add_column :invoices, :isotank_number, :string
  	add_column :invoices, :driver_phone, :string
  end

  def down
  end
end
