class UpdateKernet < ActiveRecord::Migration
  def up
    add_column :helpers, :bank_account, :string
    add_column :helpers, :bank_name, :string
    add_column :helpers, :bankexpensegroup_id, :int
    add_column :helpers, :origin, :string
    add_column :helpers, :is_resign, :boolean, :default => false
    add_column :helpers, :datein, :date
    add_column :helpers, :dateout, :date
    add_column :helpers, :blacklist, :boolean, :default => false
    add_column :helpers, :blacklist_customer_id, :int
    add_column :helpers, :blacklist_note, :string
  end

  def down
    remove_column :helpers, :bank_account
    remove_column :helpers, :bank_name
    remove_column :helpers, :bankexpensegroup_id
    remove_column :helpers, :origin
    remove_column :helpers, :is_resign
    remove_column :helpers, :datein
    remove_column :helpers, :dateout
    remove_column :helpers, :blacklist
    remove_column :helpers, :blacklist_customer_id
    remove_column :helpers, :blacklist_note
  end
end