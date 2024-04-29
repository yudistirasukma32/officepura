class AddColumnThirdpaymentToTaxinvoices < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :thirdpayment, :money, :default => 0
  	add_column :taxinvoices, :thirdpayment_date, :date
    add_column :taxinvoices, :fourthpayment, :money, :default => 0
    add_column :taxinvoices, :fourthpayment_date, :date
  end

  def down
    remove_column :taxinvoices, :thirdpayment
    remove_column :taxinvoices, :thirdpayment_date
    remove_column :taxinvoices, :fourthpayment
    remove_column :taxinvoices, :fourthpayment_date
  end
end
