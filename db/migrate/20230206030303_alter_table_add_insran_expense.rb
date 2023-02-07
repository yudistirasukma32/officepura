class AlterTableAddInsranExpense < ActiveRecord::Migration
  def up
    add_column :invoices, :is_insurance, :boolean, :default => false
    add_column :invoices, :tsi_total, :money, :default => 0

    create_table :insurancevendors, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.text      :description
      t.string    :pic
      t.string    :phone
      t.string    :mobile
      t.string    :bank_name
      t.string    :bank_account
      t.integer   :term_of_payment_in_day
      t.timestamps
    end

    create_table :insuranceexpenses, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :invoice_id
      t.integer   :insurancevendor_id
      t.text      :description 
      t.integer   :user_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.integer   :deleteuser_id
      t.timestamps
    end

    create_table :receiptinsurances, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :insuranceexpense_id
      t.text      :description 
      t.integer   :user_id
      t.string    :expensetype, :default => 'Kredit'
      t.integer   :officeexpensegroup_id
      t.integer   :bankexpensegroup_id
      t.timestamps
    end

    add_column :insuranceexpenses, :tsi_total, :money, :default => 0
    add_column :insuranceexpenses, :insurance_rate, :float, :default => 0
    add_column :insuranceexpenses, :total, :money, :default => 0

    add_column :receiptinsurances, :tsi_total, :money, :default => 0
    add_column :receiptinsurances, :insurance_rate, :float, :default => 0
    add_column :receiptinsurances, :total, :money, :default => 0

  end

  def down
    remove_column :invoices, :is_insurance
    remove_column :invoices, :tsi_total
    drop_table :insurancevendors rescue nil
    drop_table :insuranceexpenses rescue nil
    drop_table :receiptinsurances rescue nil
  end
end
