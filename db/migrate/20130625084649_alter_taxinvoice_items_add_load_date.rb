class AlterTaxinvoiceItemsAddLoadDate < ActiveRecord::Migration
  def up
  	add_column :taxinvoiceitems, :load_date, :date
  	add_column :taxinvoiceitems, :unload_date, :date
  	add_column :vehicles, :siup, :date
  end

  def down
  end
end
