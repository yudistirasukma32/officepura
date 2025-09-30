class AlterTableAddRejectroutes < ActiveRecord::Migration
  def up
    add_column :routes, :rejected, :boolean, :default => false
    add_column :routes, :rejected_at, :datetime
    add_column :routes, :rejected_by, :int
    add_column :routes, :rejected_note, :text
  end

  def down
    remove_column :routes, :rejected
    remove_column :routes, :rejected_at
    remove_column :routes, :rejected_by
    remove_column :routes, :rejected_note
  end
end