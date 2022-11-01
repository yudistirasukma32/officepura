class DelOfficeexpensegroups < ActiveRecord::Migration
  def up
    drop_table :officeexpensegroups
  end

  def down
  end
end
