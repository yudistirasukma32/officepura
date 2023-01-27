class AlterTableTaxinvitemRej < ActiveRecord::Migration
  def up
    add_column :taxinvoiceitems, :rejected, :boolean, :default => false
    add_column :taxinvoiceitems, :reject_reason, :string
  end

  def down
    remove_column :taxinvoiceitems, :rejected
    remove_column :taxinvoiceitems, :reject_reason
  end
end
