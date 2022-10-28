class AlterTableBankexpensesAddProductrequestId < ActiveRecord::Migration
  def up
  	add_column :bankexpenses, :productrequest_id, :integer
  end

  def down
  end
end
