class CreateTableAssetorder < ActiveRecord::Migration
  def up
  	create_table :assetorders, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.integer		:asset_id
  		t.date			:date
  		t.integer		:quantity
  		t.string		:unit_name
  		t.text			:description
      t.integer   :user_id
      t.integer   :deleteuser_id
  		t.timestamps
  	end

  	add_column :assetorders, :unit_price, :money, :default => 0
  	add_column :assetorders, :total, :money, :default => 0

  	create_table :assetpayments, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.integer		:assetorder_id
  		t.date			:date
  		t.text			:description
      t.integer   :user_id
      t.integer   :deleteuser_id
  		t.timestamps
  	end
  	add_column :assetpayments, :total, :money, :default => 0

    add_column :bankexpenses, :assetorder_id, :integer  
    add_column :bankexpenses, :assetpayment_id, :integer
  end

  def down
  end
end
