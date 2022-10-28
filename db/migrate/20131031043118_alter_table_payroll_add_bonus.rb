class AlterTablePayrollAddBonus < ActiveRecord::Migration
  def up
  	add_column :payrolls, :bonus, :money, :default => 0
  	add_column :payrollreturns, :bonus, :money, :default => 0
  	add_column :receiptpayrolls, :bonus, :money, :default => 0
  	add_column :receiptpayrollreturns, :bonus, :money, :default => 0
  end

  def down
  end
end
