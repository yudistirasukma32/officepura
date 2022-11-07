class AlterTableTaxinvoicesAddUserid < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :user_id, :int
  end

  def down
    remove_column :taxinvoices, :user_id
  end
end
