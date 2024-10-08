class AddDeletedUserEvents < ActiveRecord::Migration
  def up
    add_column :events, :deleteuser_id, :integer
  end

  def down
    remove_column :events, :deleteuser_id
  end
end
