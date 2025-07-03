class AddOfficeOnCust < ActiveRecord::Migration
  def up
    add_column :customers, :office_id, :int
  end

  def down
    remove_column :customers, :office_id
  end
end
