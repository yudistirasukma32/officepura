class AlterBankexpenseAddBankexpenseId < ActiveRecord::Migration
  def up
  	add_column :bankexpenses, :bankexpense_id, :integer
  end

  def down
  end
end
