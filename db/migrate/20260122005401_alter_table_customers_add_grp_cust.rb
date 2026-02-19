class AlterTableCustomersAddGrpCust < ActiveRecord::Migration
  def up
    add_column :customers, :related_customer_id, :integer
  end

  def down
    remove_column :customers, :related_customer_id
  end
end