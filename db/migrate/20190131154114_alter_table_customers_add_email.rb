class AlterTableCustomersAddEmail < ActiveRecord::Migration
  def up
  	add_column :customers, :email, :string
  end

  def down
  end
end
