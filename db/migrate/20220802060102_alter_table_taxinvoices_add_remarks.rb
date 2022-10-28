class AlterTableTaxinvoicesAddRemarks < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :remarks, :text
    add_column :taxinvoices, :insurance_cost, :money, :default => 0
    add_column :taxinvoices, :claim_cost, :money, :default => 0
  end

  def down
    remove_column :taxinvoices, :remarks
    remove_column :taxinvoices, :insurance_cost
    remove_column :taxinvoices, :claim_cost
  end
end
