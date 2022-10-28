class AlterTableofficeexpenseAddBankexpensegroupId < ActiveRecord::Migration
  def up
  	add_column	:officeexpenses, :bankexpensegroup_id, :integer
  end

  def down
  end
end
