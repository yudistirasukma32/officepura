class AlterTableEventAddDoLongId < ActiveRecord::Migration
  def up
      add_column :events, :long_id, :string, after: :enddate
      add_column :events, :station_id, :int
  end

  def down
      remove_column :events, :long_id
      remove_column :events, :station_id
  end
end
