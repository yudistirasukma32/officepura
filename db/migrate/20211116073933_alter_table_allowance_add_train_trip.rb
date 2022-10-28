class AlterTableAllowanceAddTrainTrip < ActiveRecord::Migration
  def up
		add_column :allowances, :train_trip, :money, :default => 0
  end

  def down
		remove_column :allowances, :train_trip
  end
end
