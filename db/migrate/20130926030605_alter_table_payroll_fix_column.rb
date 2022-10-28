class AlterTablePayrollFixColumn < ActiveRecord::Migration
  def up
  	remove_column :payrolls, :master_accident

  	add_column :payrolls, :master_accident, :money, :default => 0
  end

  def down
  end
end
