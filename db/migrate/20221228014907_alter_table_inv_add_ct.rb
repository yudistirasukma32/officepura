class AlterTableInvAddCt < ActiveRecord::Migration
  def up
    add_column :invoices, :cargo_type, :string
    add_column :events, :losing, :boolean, :default => false
  end

  def down
    remove_column :invoices, :cargo_type
    remove_column :events, :losing
  end
end
