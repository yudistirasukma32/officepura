class AlterTableInvoicesAddLoad < ActiveRecord::Migration
  def up
    add_column :invoices, :weight_gross, :int, :default => 0
    add_column :invoices, :load_date, :date
  end

  def down
    remove_column :invoices, :weight_gross
    remove_column :invoices, :load_date
  end
end
