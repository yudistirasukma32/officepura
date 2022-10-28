class CreateTablePaymentchecks < ActiveRecord::Migration
  def up
  	create_table :paymentchecks, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.date 			:date
  		t.string		:check_no
      t.integer   :supplier_id
  		t.timestamps
  	end 

  	add_column :paymentchecks, :total, :money, :default => 0

  	add_column :productorderitems ,:paymentcheck_id, :int
  end

  def down
  	drop_table :paymentchecks

  	remove_column :productorderitems ,:paymentcheck_id
  end
end
