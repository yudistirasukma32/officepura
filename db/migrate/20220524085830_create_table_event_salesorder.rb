class CreateTableEventSalesorder < ActiveRecord::Migration
  def up
  	create_table :eventsalesorders, :force => true do |t|
  		t.boolean   :deleted, :default => false
  		t.boolean  	:enabled, :default => true
        t.integer  	:customer_id
        t.integer  	:event_id
  		t.string    :long_id
  		t.timestamps
  	end
  end

  def down
      drop_table    :eventsalesorders rescue nil
  end
end
