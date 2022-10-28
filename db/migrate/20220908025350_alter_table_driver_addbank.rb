class AlterTableDriverAddbank < ActiveRecord::Migration
  def up
    add_column :drivers, :bank_account, :string
  end

  def down
    remove_column :drivers, :bank_account
  end
end
