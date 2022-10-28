class CreateTableRoutelocations < ActiveRecord::Migration
  def self.up 
    create_table :routelocations do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.integer :customer_id
      t.integer :route_id
      t.string :longitude_start
      t.string :latitude_start
      t.string :address_start
      t.string :longitude_end
      t.string :latitude_end
      t.string :address_end
      t.integer :status
      t.timestamps 
    end

    add_index :routelocations, [:route_id, :route_id]
    add_index :routelocations, [:customer_id, :customer_id]
 
  end
  # Drop table
  def self.down
    drop_table :routelocations rescue nil
  end
end
