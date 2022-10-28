class CreateProductOrder < ActiveRecord::Migration
  def up
  	create_table :productrequests, :force => true do |t|
    	t.boolean :deleted, :default => false
  		t.date 		:date
  		t.integer 	:driver_id
  		t.integer 	:vehicle_id
  		t.text 		:description
  		t.integer 	:productgroup_id
  		t.timestamps
  	end

  	create_table :productrequestitems, :force => true do |t|
  		t.integer 	:productrequest_id
  		t.integer 	:product_id
  		t.integer 	:quantity
  		t.integer 	:stockgiven
  		t.boolean		:requestorder, :default => false
  		t.timestamps
  	end
  	add_column :productrequestitems, :total, :money, :default => 0

  	create_table :productorders, :force => true do |t|
  		t.boolean 	:deleted, :default => false
  		t.date 			:date
  		t.text 			:description
  		t.integer 	:staff_id
  		t.integer 	:productrequest_id 
  		t.timestamps
  	end
  	add_column :productorders, :total, :money, :default => 0

  	create_table :productorderitems, :force => true do |t|
  		t.integer 	:productorder_id
  		t.integer 	:productrequestitem_id
  		t.integer 	:product_id
  		t.integer 	:quantity
  		t.integer 	:requestquantity
  		t.integer	 	:supplier_id
  		t.boolean	 	:bon
  		t.timestamps
  	end
	  add_column :productorderitems, :price_per, :money, :default => 0
  	add_column :productorderitems, :total, :money, :default => 0

  	create_table :productstocks, :force => true do |t|
  		t.boolean 	:deleted, :default => false
  		t.integer 	:product_id
  		t.integer 	:quantity
  		t.timestamps
	end

	create_table :supplierpayments, :force => true do |t|
  		t.boolean 	:deleted, :default => false
  		t.date 			:date 	
  		t.date 			:due_date
  		t.integer 	:supplier_id
  		t.string 		:no_giro
  		t.timestamps
  	end
	add_column :supplierpayments, :total, :money, :default => 0

  end

  def down
  	drop_table 	:productrequests, 
				:productrequestitems, 
				:productorders, 
				:productorderitems,
				:productstocks,
				:supplierpayments
  end
end
