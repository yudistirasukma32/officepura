class AlterTableOfficeexpensesAddContAndIso < ActiveRecord::Migration
  def up
    add_column :officeexpenses, :container_id, :int
    add_column :officeexpenses, :isotank_id, :int
  end

  def down
    remove_column :officeexpenses, :container_id 
    remove_column :officeexpenses, :isotank_id 
  end
end
