class AddCustTaxinv3 < ActiveRecord::Migration
  def up
    add_column :customers, :bank_id, :int
    add_column :customers, :memo, :string
  end

  def down
    remove_column :customers, :bank_id
    remove_column :customers, :memo
  end
end
