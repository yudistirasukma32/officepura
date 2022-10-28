class AlterTableInvoiceAddTank < ActiveRecord::Migration
  def up
    add_column :invoices, :container_id, :int
    add_column :invoices, :tanktype, :string 
  end

  def down
    remove_column :invoices, :container_id 
    remove_column :invoices, :tanktype 
  end
end
