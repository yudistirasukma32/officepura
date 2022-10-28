class AlterTableTaxinvoiceAddIsweightlost < ActiveRecord::Migration
  def up
  	remove_column :customers, :price_by
  	remove_column :taxinvoices, :is_net
  	remove_column :taxinvoices, :is_gross
  	remove_column :taxinvoices, :is_wholesale

  	add_column :taxinvoices, :price_by, :string
  	add_column :taxinvoices, :is_weightlost, :boolean, :detault => false
  end

  def down
  end
end
