class AlterTableEventsAddCanceled < ActiveRecord::Migration
  def up
  	add_column :events, :cancelled, :boolean, :default => false
  end

  def down
  end
end
