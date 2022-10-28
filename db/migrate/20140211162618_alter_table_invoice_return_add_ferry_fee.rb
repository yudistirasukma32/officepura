class AlterTableInvoiceReturnAddFerryFee < ActiveRecord::Migration
  def up
  	add_column :invoicereturns, :ferry_fee, :money, :default => 0
  	add_column :receiptreturns, :ferry_fee, :money, :default => 0
  end

  def down
  end
end
