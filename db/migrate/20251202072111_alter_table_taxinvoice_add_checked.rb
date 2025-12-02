class AlterTableTaxinvoiceAddChecked < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :checked, :boolean, :default => false
    add_column :taxinvoices, :checked_by, :integer
  end

  def down
    remove_column :taxinvoices, :checked
    remove_column :taxinvoices, :checked_by 
  end
end