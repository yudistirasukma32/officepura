class CreateTableCommodities < ActiveRecord::Migration
  def up
  	create_table :commodities, :force => true do |t|
      t.boolean   :deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.string    :description
      t.timestamps
  	end
      
    # Assign existing to default site
    # default = Commodity.new
    # default.name = "Kelapa Sawit"
    # default.save

    add_column :events, :commodity_id, :int
      
  end

  def down
      drop_table    :commodities rescue nil
      remove_column :events, :commodity_id
  end
end
