class AlterTableEventsAddLoaddate < ActiveRecord::Migration
  def up
    add_column :events, :load_date, :date
  	add_column :events, :unload_date, :date
  end

  def down
    remove_column :events, :load_date
    remove_column :events, :unload_date
  end
end
