class AddOfficeDriverKernet < ActiveRecord::Migration
  def up
    add_column :drivers, :office_id, :int
    add_column :helpers, :office_id, :int
  end

  def down
    remove_column :drivers, :office_id
    remove_column :helpers, :office_id
  end
end