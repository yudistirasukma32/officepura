class AlterTableRouteAddTypes < ActiveRecord::Migration
  def up
		add_column :routes, :is_sea, :boolean, :default => false
    add_column :routes, :is_isotank, :boolean, :default => false
  end

  def down
		remove_column :routes, :is_sea
    remove_column :routes, :is_isotank
  end
end
