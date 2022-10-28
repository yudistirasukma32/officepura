class AlterTableInvoicesAddGasstart < ActiveRecord::Migration
  def up
  	add_column :invoices, :gas_start, :integer, :default => 0
  end

  def down
  end
end
