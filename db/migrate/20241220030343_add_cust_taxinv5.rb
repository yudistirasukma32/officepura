class AddCustTaxinv5 < ActiveRecord::Migration
  def up
    add_column :customers, :memo_address, :string
  end

  def down
    remove_column :customers, :memo_address
  end
end