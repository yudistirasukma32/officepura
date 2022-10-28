class AlterTableInvoiceAddIsoCont < ActiveRecord::Migration
  def up
    add_column :invoices, :container_number, :string
    add_column :invoices, :isotank_number, :string 
  end

  def down
    remove_column :invoices, :container_number 
    remove_column :invoices, :isotank_number 
  end
end
