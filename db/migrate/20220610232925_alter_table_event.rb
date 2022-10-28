class AlterTableEvent < ActiveRecord::Migration
  def up
    add_column :events, :route_summary, :string
  end

  def down
    remove_column :events, :route_summary
  end
end
