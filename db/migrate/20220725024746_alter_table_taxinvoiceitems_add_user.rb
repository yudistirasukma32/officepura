class AlterTableTaxinvoiceitemsAddUser < ActiveRecord::Migration
  def up
    add_column :taxinvoiceitems, :user_id, :int
  end

  def down
    remove_column :taxinvoiceitems, :user_id
  end
end
