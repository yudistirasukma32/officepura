class AlterTableDriverPrepareDms < ActiveRecord::Migration
  def up
    add_column :drivers, :auth_id, :uuid

    add_column :driverlogs, :log_type, :string
    add_column :driverlogs, :date, :date
    add_column :driverlogs, :response, :text
    add_column :driverlogs, :vehicle_id, :int
    add_column :driverlogs, :approved, :boolean, :default => false
 
  end

  def down
    remove_column :drivers, :auth_id

    remove_column :driverlogs, :log_type 
    remove_column :driverlogs, :date 
    remove_column :driverlogs, :response 
    remove_column :driverlogs, :vehicle_id 
    remove_column :driverlogs, :approved 
  end
end