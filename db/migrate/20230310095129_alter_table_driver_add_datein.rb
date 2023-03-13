class AlterTableDriverAddDatein < ActiveRecord::Migration
  def up
    add_column :drivers, :datein, :date
    add_column :drivers, :dateout, :date
  end

  def down
    remove_column :drivers, :datein
    remove_column :drivers, :dateout
  end
end
