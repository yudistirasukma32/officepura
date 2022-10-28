class CreateTableRouteTrain < ActiveRecord::Migration
  def up
    create_table :routetrains, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :container_type
      t.string    :size
      t.integer   :operator_id
      t.integer   :origin_station_id
      t.integer   :destination_station_id
      t.timestamps
    end

    create_table :trainexpenses, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :routetrain_id
      t.integer   :invoice_id
      t.text      :description 
      t.integer   :user_id
      t.timestamps
    end

    create_table :receipttrains, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.date 			:date
      t.integer   :trainexpense_id
      t.text      :description 
      t.integer   :user_id
      t.timestamps
    end

    add_column :routetrains, :price_per, :money, :default => 0
    add_column :trainexpenses, :total, :money, :default => 0
    add_column :receipttrains, :total, :money, :default => 0
  end

  def down
    drop_table    :routetrains rescue nil
    drop_table    :trainexpenses rescue nil
    drop_table    :receipttrains rescue nil
  end
end
