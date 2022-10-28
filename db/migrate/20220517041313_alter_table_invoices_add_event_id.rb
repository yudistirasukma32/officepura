class AlterTableInvoicesAddEventId < ActiveRecord::Migration
  def up
    add_column :invoices, :event_id, :int
  end

  def down
    remove_column :invoices, :event_id
  end
end
