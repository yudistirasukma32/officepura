class AlterTableBankexpensesAddTaxinvoiceId < ActiveRecord::Migration
  def up
  	add_column :bankexpenses, :productorder_id, :integer
  end

  def down
  end
end
