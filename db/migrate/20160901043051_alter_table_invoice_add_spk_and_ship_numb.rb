class AlterTableInvoiceAddSpkAndShipNumb < ActiveRecord::Migration
  def up
  	add_column :invoices, :spk_number, :string
  end

  def down
  end
end
