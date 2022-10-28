class AlterTableBankexpensegroups < ActiveRecord::Migration
  def up
  	add_column :bankexpensegroups, :inreport, :boolean, :default => false
  end

  def down
  end
end
