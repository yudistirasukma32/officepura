class CreateReceipts < ActiveRecord::Migration
  def up

  create_table :receipts, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.integer  	:invoice_id
		t.integer  	:quantity
		t.text  		:description
		t.integer  	:office_id
		t.timestamps
	end
	add_column :receipts, :driver_allowance, :money, :default => 0
	add_column :receipts, :gas_allowance, :money, :default => 0
	add_column :receipts, :total, :money, :default => 0

	create_table :receiptreturns, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.integer  	:invoice_id
		t.integer  	:quantity
		t.text  		:description
		t.integer  	:office_id
		t.timestamps
	end
	add_column :receiptreturns, :driver_allowance, :money, :default => 0
	add_column :receiptreturns, :gas_allowance, :money, :default => 0
	add_column :receiptreturns, :tol_fee, :money, :default => 0
	add_column :receiptreturns, :total, :money, :default => 0

	create_table :receiptexpenses, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.integer 	:officeexpense_id
		t.integer 	:officeexpensegroup_id
		t.string 		:expensetype
		t.timestamps
	end

	add_column :receiptexpenses, :total, :money, :default => 0 

	create_table :receiptpremis, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.integer 	:invoice_id
		t.date			:date
		t.integer 	:bonusreceipt_id
		t.timestamps
	end

	add_column :receiptpremis, :total, :money ,:default => 0

	create_table :receiptorders, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.date			:date
		t.integer 	:productorder_id
		t.timestamps
	end

	add_column :receiptorders, :total, :money, :default => 0
	add_column :receiptorders, :bon, :money, :default => 0

  create_table :cashdailylogs, :force => true do |t|
    t.date  :date
    t.timestamps
  end
  add_column :cashdailylogs, :total, :money, :default => 0 

  end

  def down
  	drop_table 	:receipts, 
				        :receipt_returns,
				        :receiptorders,
   				      :receiptpremis,
   				      :receiptexpenses,
                :cashdailylogs
 
  end
end
