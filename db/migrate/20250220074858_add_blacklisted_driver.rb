class AddBlacklistedDriver < ActiveRecord::Migration
  def up
    add_column :drivers, :blacklist, :boolean, :default => false
    add_column :drivers, :blacklist_customer_id, :int
    add_column :drivers, :blacklist_note, :string
  end

  def down
    remove_column :drivers, :blacklist
    remove_column :drivers, :blacklist_customer_id
    remove_column :drivers, :blacklist_note
  end
end