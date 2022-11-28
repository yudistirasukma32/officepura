class AlterTableRouteshipsAddTempo < ActiveRecord::Migration
  def up
    add_column :routeships, :tempo, :int, :default => 0
    add_column :routeships, :description, :string
  end

  def down
    remove_column :routeships, :tempo
    remove_column :routeships, :description
  end
end
