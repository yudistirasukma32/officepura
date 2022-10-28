class AlterTableInvAddTrainroute < ActiveRecord::Migration
  def up
    add_column :invoices, :routetrain_id, :int
  end

  def down
    remove_column :invoices, :routetrain_id
  end
end
