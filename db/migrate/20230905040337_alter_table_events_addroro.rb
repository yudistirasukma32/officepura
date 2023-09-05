class AlterTableEventsAddroro < ActiveRecord::Migration
  def up
    add_column :events, :invoiceship, :boolean, :default => false
  end

  def down
    remove_column :events, :invoiceship
  end
end
