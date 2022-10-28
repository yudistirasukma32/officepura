class AlterTableOfficeexpensesAddBankexpenseId < ActiveRecord::Migration
  def up
  	add_column :officeexpenses, :bankexpense_id, :integer
  end

  def down
  end
end
