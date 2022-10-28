class AlterTableTaxinvoices < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :duedate, :date
  	add_column :taxinvoices, :paiddate, :date
  end

  def down
  	remove_column :taxinvoices,:duedate
  	remove_column :taxinvoices, :paiddate
  end
end
