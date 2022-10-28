class AlterTableRouteAddRouteId < ActiveRecord::Migration
  def up
    add_column :routes, :route_id, :int
  end

  def down
    remove_column :routes, :route_id
  end
end
