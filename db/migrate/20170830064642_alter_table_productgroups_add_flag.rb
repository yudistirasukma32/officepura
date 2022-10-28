class AlterTableProductgroupsAddFlag < ActiveRecord::Migration
  def up
  	add_column :productgroups, :tire_flag, :boolean, :default => false
  end

  def down
  end
end
