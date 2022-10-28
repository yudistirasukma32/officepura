class CreateTableProductPriceLogs < ActiveRecord::Migration
  def up
  	create_table :productpricelogs, :force => true do |t|
		t.integer :product_id
		t.timestamps
	end

	add_column :productpricelogs, :old_price, :money, :default => 0
	add_column :productpricelogs, :new_price, :money, :default => 0
  end

  def down
  	drop_table :productpricelogs
  end
end
