class AddMultiContainerEvent < ActiveRecord::Migration
  def up
    add_column :events, :multicontainer, :boolean, :default => false
  end

  def down
    remove_column :events, :multicontainer
  end
end
