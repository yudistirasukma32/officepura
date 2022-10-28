class AlterTableVehiclesAddTeraDate < ActiveRecord::Migration
  def up
  	add_column :vehicles, :next_tera_date, :date
  end

  def down
  end
end
