class AlterTableInvoices < ActiveRecord::Migration
  def up
  	remove_column :invoices, :isotank_number

  	add_column :invoices, :isotank_id, :int
  end

  def down
  end
end
