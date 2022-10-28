class AlterTableEventsAddUser < ActiveRecord::Migration
  def up
    add_column :events, :user_id, :int
  end

  def down
    remove_column :events, :user_id
  end
end
