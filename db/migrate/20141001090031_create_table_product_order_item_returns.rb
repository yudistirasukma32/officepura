class CreateTableProductOrderItemReturns < ActiveRecord::Migration
  def up
  	create_table :productorderitemreturns, :force => true do |t|
  		t.integer 	:productorder_id
  		t.integer 	:product_id
  		t.integer 	:quantity
  		t.integer	:supplier_id
  		t.boolean	:bon
  		t.timestamps
  	end
	add_column :productorderitemreturns, :price_per, :money, :default => 0
  	add_column :productorderitemreturns, :total, :money, :default => 0
  end

  def down
  end
end
