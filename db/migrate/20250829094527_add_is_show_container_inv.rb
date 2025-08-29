class AddIsShowContainerInv < ActiveRecord::Migration
  def up
    add_column :taxinvoices, :is_show_container, :boolean, :default => false
  end

  def down
    remove_column :taxinvoices, :is_show_container
  end
end
