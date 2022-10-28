class AlterTableCustomerAddPriceby < ActiveRecord::Migration
  def up
  	add_column :customers, :price_by, :string
  end

  def down
  	remove_column :customers, :price_by
  end
end
