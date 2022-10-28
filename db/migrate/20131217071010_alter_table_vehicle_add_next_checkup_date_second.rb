class AlterTableVehicleAddNextCheckupDateSecond < ActiveRecord::Migration
  def up
  	add_column :vehicles, :next_checkup_date_second, :date
  end

  def down
  end
end
