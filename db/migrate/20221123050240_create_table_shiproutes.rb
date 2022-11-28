class CreateTableShiproutes < ActiveRecord::Migration
  def up
    create_table :routeships, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.boolean  	:enabled, :default => true
      t.string    :name
      t.integer   :operator_id
      t.integer   :origin_port_id
      t.integer   :destination_port_id
      t.timestamps
  end
  add_column :routeships, :price_per, :money, :default => 0

  add_column :operators, :operatortype, :string
end

  def down
    drop_table :routeships rescue nil
    remove_column :routeships, :price_per
    remove_column :operators, :operatortype
  end
end
