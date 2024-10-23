class TaxinvoiceDp < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :is_dp, :boolean, :default => false
    add_column :taxinvoices, :dp_cost, :money, :default => 0
    
  end

  def down
    remove_column :taxinvoices, :is_dp
    remove_column :taxinvoices, :dp_cost
  end
end
