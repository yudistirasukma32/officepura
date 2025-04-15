class AddApprovalRoutes < ActiveRecord::Migration
  def up
    add_column :routes, :approved, :boolean, :default => false
    add_column :routes, :approved_at, :datetime
    add_column :routes, :approved_by, :int
    add_column :routes, :user_id, :int
  end

  def down
    remove_column :routes, :approved
    remove_column :routes, :approved_at
    remove_column :routes, :approved_by
    remove_column :routes, :user_id
  end
end