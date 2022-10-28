class CreateTableEventMemos < ActiveRecord::Migration
  def up
    create_table :eventmemos, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer  	:event_id
      t.integer  	:driver_id
      t.integer  	:customer_id
      t.integer  	:vehicle_id
      t.integer   :commodity_id  
      t.integer  	:quantity, :default => 0
      t.integer   :route_id
      t.string    :route_summary
      t.integer   :container_id
      t.integer   :isotank_id 
      t.string    :driver_phone 
      t.text      :description
      t.timestamps
    end

    create_table :eventcleaningmemos, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer  	:event_id
      t.integer  	:driver_id
      t.integer  	:vehicle_id
      t.integer   :container_id
      t.integer   :isotank_id
      t.text      :description
      t.text      :next_description
      t.timestamps
    end

    add_column :events, :route_id, :int
    add_column :events, :truck_quantity, :int
  
  end

  def down
    drop_table    :eventmemos rescue nil
    drop_table    :eventcleaningmemos rescue nil
    remove_column :events, :route_id
    remove_column :events, :truck_quantity
  end
end
