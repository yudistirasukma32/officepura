class AddDiscountTaxinv < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :discount_percent, :float, :default => 0
    add_column :taxinvoices, :discount_amount, :money, :default => 0
  end

  def down
    remove_column :taxinvoices, :discount_percent
    remove_column :taxinvoices, :discount_amount
  end
end