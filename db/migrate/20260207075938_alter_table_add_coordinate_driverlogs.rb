class AlterTableAddCoordinateDriverlogs < ActiveRecord::Migration
  def up
    add_column :driverlogs, :longitude, :string
    add_column :driverlogs, :latitude, :string
  end

  def down
    remove_column :driverlogs, :longitude
    remove_column :driverlogs, :latitude
  end
end
