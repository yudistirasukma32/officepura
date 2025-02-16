class AddContainerTypes < ActiveRecord::Migration
  def up
    add_column :isotanks, :group, :string
    add_column :containers, :group, :string
    add_column :invoices, :multicontainer, :boolean, :default => false
    add_column :invoices, :second_container_id, :integer
    add_column :invoices, :second_isotank_id, :integer
  end

  def down
    remove_column :isotanks, :group
    remove_column :containers, :group
    remove_column :invoices, :multicontainer
    remove_column :invoices, :second_container_id
    remove_column :invoices, :second_isotank_id
  end
end