class AddColumnRouteshipidToEvents < ActiveRecord::Migration
  def up
    add_column :events, :routeship_id, :integer
    add_column :invoices, :is_approval_operator, :boolean, :default => false
    add_column :invoices, :approval_operator_confirmed_by, :integer
    add_column :routes, :load_province, :string
    add_column :routes, :unload_province, :string
  end

  def down
    remove_column :events, :routeship_id
    remove_column :invoices, :is_approval_operator
    remove_column :invoices, :approval_operator_confirmed_by
    remove_column :routes, :load_province
    remove_column :routes, :unload_province
  end
end
