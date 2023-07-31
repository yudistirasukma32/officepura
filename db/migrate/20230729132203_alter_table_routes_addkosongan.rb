class AlterTableRoutesAddkosongan < ActiveRecord::Migration
  def up
    add_column :routes, :kosongan, :boolean, :default => false
    add_column :routes, :kosongan_type, :string
    add_column :routes, :project, :boolean, :default => false
  end

  def down
    remove_column :routes, :kosongan
    remove_column :routes, :kosongan_type
    remove_column :routes, :project
  end
end
