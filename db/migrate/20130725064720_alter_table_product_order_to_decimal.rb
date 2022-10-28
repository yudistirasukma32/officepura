class AlterTableProductOrderToDecimal < ActiveRecord::Migration
  def up
  	change_column :productrequestitems, :quantity, :decimal
  	change_column :productrequestitems, :stockgiven, :decimal
  	change_column :productorderitems, :quantity, :decimal
  	change_column :productorderitems, :requestquantity, :decimal
  	change_column :products, :stock, :decimal
  end

  def down
  end
end
