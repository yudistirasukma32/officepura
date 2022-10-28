class AlterTableCustomerAddWholesaleprice < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :is_wholesale, :boolean, :default => :false
  	add_column :customers, :wholesale_price, :money, :default => 0
	add_column :taxinvoiceitems, :is_wholesale, :boolean, :default => :false
  	add_column :taxinvoiceitems, :wholesale_price, :money, :default => 0
  end

  def down
  end
end
