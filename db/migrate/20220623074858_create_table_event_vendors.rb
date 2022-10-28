class CreateTableEventVendors < ActiveRecord::Migration
  def up
      
    create_table :eventvendors, :force => true do |t|
  		t.boolean   :deleted, :default => false
  		t.boolean  	:enabled, :default => true
        t.integer  	:event_id
  		t.string    :name
        t.string    :vehicle_current_id
        t.string    :iso_cont_number
        t.integer   :quantity 
  		t.timestamps
  	end
      
    add_column :events, :need_vendor, :boolean, :default => false

  end

  def down
      
      drop_table    :stations rescue nil

      remove_column :events, :need_vendor      
      
  end
end
