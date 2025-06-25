class AddMarketingOnInv < ActiveRecord::Migration
  def up
    add_column :invoices, :marketing_id, :int
  end

  def down
    remove_column :invoices, :marketing_id 
  end
end
