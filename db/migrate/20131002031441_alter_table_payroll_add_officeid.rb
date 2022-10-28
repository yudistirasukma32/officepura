class AlterTablePayrollAddOfficeid < ActiveRecord::Migration
  def up
  	add_column :payrolls, :office_id, :integer
  end

  def down
  end
end
