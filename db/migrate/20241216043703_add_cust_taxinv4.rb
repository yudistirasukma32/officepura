class AddCustTaxinv4 < ActiveRecord::Migration
  def up
    add_column :customers, :memo_attachments, :string
    add_column :customers, :memo_info, :string
  end

  def down
    remove_column :customers, :memo_attachments
    remove_column :customers, :memo_info
  end
end
