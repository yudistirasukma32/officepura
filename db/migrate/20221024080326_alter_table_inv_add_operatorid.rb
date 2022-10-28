class AlterTableInvAddOperatorid < ActiveRecord::Migration
  def up
    add_column :invoices, :operator_id, :int
  end

  def down
    remove_column :invoices, :operator_id
  end
end
