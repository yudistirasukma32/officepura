class AddColumnSecondphoneToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :phone2, :string
    add_column :customers, :phone3, :string
    add_column :customers, :mobile2, :string
    add_column :customers, :mobile3, :string
  end
end
