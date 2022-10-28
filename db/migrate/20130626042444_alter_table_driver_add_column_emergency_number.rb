class AlterTableDriverAddColumnEmergencyNumber < ActiveRecord::Migration
  def up
  	add_column :drivers, :emergency_number, :string
  	add_column :helpers, :emergency_number, :string
  end

  def down
  end
end
