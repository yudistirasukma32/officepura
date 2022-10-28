class CreateTableInvoiceDriver < ActiveRecord::Migration
  def up
     create_table :payrolls, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.date    :date
      t.date    :period_start
      t.date    :period_end
      t.integer :driver_id
      t.integer :helper_id
      t.integer :vehicle_id
      t.integer   :holidays
      t.integer   :non_holidays
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    add_column :payrolls, :holidays_payment, :money, :default => 0
    add_column :payrolls, :non_holidays_payment, :money, :default => 0
    add_column :payrolls, :holidays_fare, :money, :default => 0
    add_column :payrolls, :non_holidays_fare, :money, :default => 0
    add_column :payrolls, :weight_loss, :money, :default => 0
    add_column :payrolls, :accident, :money, :default => 0
    add_column :payrolls, :sparepart, :money, :default => 0
    add_column :payrolls, :bon, :money, :default => 0
    add_column :payrolls, :allowance, :money, :default => 0
    add_column :payrolls, :saving, :money, :default => 0
    add_column :payrolls, :saving_reduction, :money, :default => 0
    add_column :payrolls, :total, :money, :default => 0

    create_table :receiptpayrolls, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.integer   :payroll_id 
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    add_column :receiptpayrolls, :holidays_payment, :money, :default => 0
    add_column :receiptpayrolls, :non_holidays_payment, :money, :default => 0
    add_column :receiptpayrolls, :weight_loss, :money, :default => 0
    add_column :receiptpayrolls, :accident, :money, :default => 0
    add_column :receiptpayrolls, :sparepart, :money, :default => 0
    add_column :receiptpayrolls, :bon, :money, :default => 0
    add_column :receiptpayrolls, :allowance, :money, :default => 0
    add_column :receiptpayrolls, :saving, :money, :default => 0
    add_column :receiptpayrolls, :saving_reduction, :money, :default => 0
    add_column :receiptpayrolls, :total, :money, :default => 0

    create_table :payrollreturns, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.date      :date
      t.integer   :payroll_id
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps  
    end

    add_column :payrollreturns, :holidays_payment, :money, :default => 0
    add_column :payrollreturns, :non_holidays_payment, :money, :default => 0
    add_column :payrollreturns, :weight_loss, :money, :default => 0
    add_column :payrollreturns, :accident, :money, :default => 0
    add_column :payrollreturns, :sparepart, :money, :default => 0
    add_column :payrollreturns, :bon, :money, :default => 0
    add_column :payrollreturns, :allowance, :money, :default => 0
    add_column :payrollreturns, :saving, :money, :default => 0
    add_column :payrollreturns, :saving_reduction, :money, :default => 0
    add_column :payrollreturns, :total, :money, :default => 0

    create_table :receiptpayrollreturns, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.integer   :payroll_id
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.timestamps  
    end

    add_column :receiptpayrollreturns, :holidays_payment, :money, :default => 0
    add_column :receiptpayrollreturns, :non_holidays_payment, :money, :default => 0
    add_column :receiptpayrollreturns, :weight_loss, :money, :default => 0
    add_column :receiptpayrollreturns, :accident, :money, :default => 0
    add_column :receiptpayrollreturns, :sparepart, :money, :default => 0
    add_column :receiptpayrollreturns, :bon, :money, :default => 0
    add_column :receiptpayrollreturns, :allowance, :money, :default => 0
    add_column :receiptpayrollreturns, :saving, :money, :default => 0
    add_column :receiptpayrollreturns, :saving_reduction, :money, :default => 0
    add_column :receiptpayrollreturns, :total, :money, :default => 0

    add_column :drivers, :weight_loss, :money, :default => 0
    add_column :drivers, :accident, :money, :default => 0
    add_column :drivers, :sparepart, :money, :default => 0
    add_column :drivers, :bon, :money, :default => 0
    add_column :drivers, :saving, :money, :default => 0
    

    add_column :helpers, :weight_loss, :money, :default => 0
    add_column :helpers, :accident, :money, :default => 0
    add_column :helpers, :sparepart, :money, :default => 0
    add_column :helpers, :bon, :money, :default => 0
    add_column :helpers, :saving, :money, :default => 0

    remove_column :driverexpenses, :expensetype
    add_column :driverexpenses, :user_id, :integer
    add_column :driverexpenses, :helper_id, :integer
    add_column :driverexpenses, :weight_loss, :money, :default => 0
    add_column :driverexpenses, :accident, :money, :default => 0
    add_column :driverexpenses, :sparepart, :money, :default => 0
    add_column :driverexpenses, :bon, :money, :default => 0

    remove_column :receiptdrivers, :expensetype
    add_column :receiptdrivers, :weight_loss, :money, :default => 0
    add_column :receiptdrivers, :accident, :money, :default => 0
    add_column :receiptdrivers, :sparepart, :money, :default => 0
    add_column :receiptdrivers, :bon, :money, :default => 0
  end

  def down
  end
end
