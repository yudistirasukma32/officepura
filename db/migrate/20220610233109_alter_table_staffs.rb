class AlterTableStaffs < ActiveRecord::Migration
  def up
    add_column :staffs, :office_id, :int
  end

  def down
    remove_column :staffs, :office_id
  end
end
