class AlterTableTaxinvoicesAddIsgross < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :is_gross, :boolean, :default => false
  	add_column :taxinvoices, :is_net, :boolean, :default => false
  	add_column :taxinvoiceitems, :is_gross, :boolean, :default => false
  	add_column :taxinvoiceitems, :is_net, :boolean, :default => false
  end

  def down
  end
end
