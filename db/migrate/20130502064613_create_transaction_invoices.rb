class CreateTransactionInvoices < ActiveRecord::Migration
  def up
  	create_table :invoices, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.boolean  	:enabled, :default => true
		t.date 			:date
		t.string  	:ship_name
		t.integer  	:driver_id
		t.integer  	:customer_id
		t.integer  	:vehicle_id
		t.integer  	:route_id
		t.integer  	:vehiclegroup_id
		t.integer  	:quantity
		t.integer  	:gas_litre, :default => 0
		t.integer  	:gas_voucher, :default => 0
		t.integer  	:gas_leftover, :default => 0
		t.float  	:insurance_rate, :default => 0.0
		t.string  	:trip_type
		t.text  	:description
		t.integer  	:office_id
		t.integer 	:invoice_id
		t.timestamps
	end
	add_column :invoices, :gas_cost, :money, :default => 0
	add_column :invoices, :gas_allowance, :money, :default => 0
	add_column :invoices, :driver_allowance, :money, :default => 0
	add_column :invoices, :ferry_fee, :money, :default => 0
	add_column :invoices, :tol_fee, :money, :default => 0
	add_column :invoices, :price_per, :money, :default => 0
	add_column :invoices, :insurance, :money, :default => 0
	add_column :invoices, :total, :money, :default => 0

	create_table :invoicereturns, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.date 			:date
		t.integer  	:invoice_id
		t.integer  	:quantity
		t.integer  	:gas_leftover, :default => 0
		t.text  		:description
		t.integer  	:office_id
		t.timestamps
	end
	add_column :invoicereturns, :driver_allowance, :money, :default => 0
	add_column :invoicereturns, :gas_allowance, :money, :default => 0
	add_column :invoicereturns, :tol_fee, :money, :default => 0
	add_column :invoicereturns, :total, :money, :default => 0

	create_table :taxinvoices, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.date 			:date
		t.string  	:long_id
		t.string  	:ship_name
		t.text  		:description
		t.integer  	:customer_id
		t.integer  	:office_id
		t.timestamps
	end
	add_column :taxinvoices, :total, :money, :default => 0
	add_column :taxinvoices, :gst_tax, :money, :default => 0
	add_column :taxinvoices, :price_tax, :money, :default => 0

	create_table :taxinvoiceitems, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.datetime 	:date
		t.string  	:sku_id
		t.integer 	:weight_gross, :default => 0
		t.integer  	:weight_net, :default => 0
		t.text  	:description
		t.integer  	:invoice_id
		t.integer  	:customer_id
		t.integer  	:taxinvoice_id
		t.integer  	:office_id
		t.timestamps
	end
	add_column :taxinvoiceitems, :price_per, :money, :default => 0
	add_column :taxinvoiceitems, :total, :money, :default => 0

	create_table :bonusreceipts, :force => true do |t|
		t.boolean 	:deleted, :default => false
		t.integer  	:invoice_id
		t.integer  	:quantity
		t.text  		:description
		t.integer  	:office_id
		t.timestamps
	end
	add_column :bonusreceipts, :total, :money, :default => 0
  end

  def down
  	drop_table 	:invoices, 
				:invoicereturns, 
				:taxinvoices,
				:taxinvoiceitems,
				:bonusreceipts
  
  end
end
