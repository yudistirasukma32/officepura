class AddCitiesRoutes < ActiveRecord::Migration
  def up
    add_column :routes, :load_city, :string
    add_column :routes, :unload_city, :string
  end

  def down
    remove_column :routes, :load_city
    remove_column :routes, :unload_city
  end
end
