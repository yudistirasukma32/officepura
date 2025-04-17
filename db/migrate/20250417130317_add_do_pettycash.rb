class AddDoPettycash < ActiveRecord::Migration
  def up
    add_column :officeexpenses, :event_id, :int
  end

  def down
    remove_column :officeexpenses, :event_id
  end
end
