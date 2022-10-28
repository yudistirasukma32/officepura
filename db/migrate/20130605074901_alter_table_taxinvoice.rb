class AlterTableTaxinvoice < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :period_start, :date
  	add_column :taxinvoices, :period_end, :date
  	add_column :taxinvoices, :product_name, :string
  	add_column :taxinvoices, :spk_no,:string
  	add_column :taxinvoices, :po_no, :string
  	add_column :taxinvoices, :tank_name, :string
  end

  def down
  end
end
