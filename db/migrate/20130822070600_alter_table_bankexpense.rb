class AlterTableBankexpense < ActiveRecord::Migration
  def up
  	add_column :bankexpenses, :deleteuser_id, :int
  end

  def down
  	remove_column :bankexpenses, :deleteuser_id
  end
end
