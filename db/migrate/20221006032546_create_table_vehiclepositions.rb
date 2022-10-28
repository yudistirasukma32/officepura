class CreateTableVehiclepositions < ActiveRecord::Migration
  def self.up 
    create_table :vehiclepositions do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.date  :date
      t.integer :hour
      t.integer :event_id
      t.integer :invoice_id
      t.integer :vehicle_id
      t.integer :driver_id
      t.integer :route_id
      t.string :longitude
      t.string :latitude
      t.string :description
      t.integer :status
      t.timestamps 
    end
 
  end
  # Drop table
  def self.down
    drop_table :vehiclepositions rescue nil
  end
end
