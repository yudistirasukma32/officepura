class AlterTableBankexpensegroupAddBankexpensegroupId < ActiveRecord::Migration
  def up
  	add_column	:bankexpensegroups, :bankexpensegroup_id, :integer
  end

  def down
  end
end
