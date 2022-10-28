class CreateTableSalesproduct < ActiveRecord::Migration
  def up
  	create_table :productsales, :force => true do |t|
  		t.boolean 	:deleted, :default => false
  		t.boolean 	:onsale, :default => false
  		t.string 	:name
  		t.string	:unit_name
  		t.timestamps
  	end

  	add_column :productsales, :unit_price, :money, :default => 0

  	create_table :sales, :force => true do |t|
  		t.boolean 	:deleted, :default => false
  		t.date		:date
  		t.text		:description
  		t.integer	:user_id
  		t.timestamps
  	end

    add_column :sales, :total, :money, :default => 0

  	create_table :saleitems, :force => true do |t|
  		t.integer 	:sale_id
  		t.integer	:productsale_id
  		t.integer	:quantity
  		t.timestamps
  	end

  	add_column :saleitems, :price_per, :money, :default => 0
  	add_column :saleitems, :total, :money, :default => 0

  	create_table :receiptsales, :force => true do |t|
  		t.boolean 	:deleted, :default => false
  		t.date		:date
  		t.integer	:sale_id
  		t.integer 	:user_id
  		t.timestamps
  	end

  	add_column :receiptsales, :total, :money, :default => 0

  end

  def down
    
  	drop_table  :productsales
    drop_table  :sales 
    drop_table  :saleitems
    drop_table  :receiptsales
    
  end
end
