class AddShowLoadUnloadVehicle < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :is_show_loadunload, :boolean, :default => false
  end

  def down
    remove_column :taxinvoices, :is_show_loadunload
  end
end