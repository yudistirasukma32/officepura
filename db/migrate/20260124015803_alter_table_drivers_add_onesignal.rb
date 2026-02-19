class AlterTableDriversAddOnesignal < ActiveRecord::Migration
  def up
    add_column :drivers, :onesignal_id, :string
  end

  def down
    remove_column :drivers, :onesignal_id
  end
end
