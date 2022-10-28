class CreateIncentiveItems < ActiveRecord::Migration
  def up

		create_table :incentives, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.integer  	:invoice_id
			t.integer  	:quantity
			t.text  		:description
			t.integer  	:office_id
			t.integer		:user_id
			t.integer		:deleteuser_id
			t.timestamps
		end

		add_column :incentives, :total, :money, :default => 0

		create_table :receiptincentives, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.integer 	:invoice_id
			t.date			:date
			t.integer 	:incentive_id
			t.integer		:user_id
			t.integer		:deleteuser_id
			t.timestamps
		end

		add_column :receiptincentives, :total, :money ,:default => 0 rescue nil

  	add_column :invoices, :incentive, :money, :default => 0 rescue nil

  end

  def down
  	drop_table :incentives rescue nil
  	drop_table :receiptincentives rescue nil
  end
end
