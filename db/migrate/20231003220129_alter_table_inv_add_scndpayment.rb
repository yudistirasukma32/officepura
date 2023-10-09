class AlterTableInvAddScndpayment < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :secondpayment, :money, :default => 0
  	add_column :taxinvoices, :secondpayment_date, :date
  end

  def down
  end
end
