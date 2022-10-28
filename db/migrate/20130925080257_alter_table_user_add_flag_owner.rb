class AlterTableUserAddFlagOwner < ActiveRecord::Migration
  def up
  	add_column :users, :owner, :boolean, :default => false
  end

  def down
  end
end
