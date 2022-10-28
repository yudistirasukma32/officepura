class AlterTableOfficeexpenses < ActiveRecord::Migration
  def up
  	add_column :officeexpenses, :office_id, :int
  	add_column :bankexpenses, :office_id, :int
  end

  def down
  end
end
