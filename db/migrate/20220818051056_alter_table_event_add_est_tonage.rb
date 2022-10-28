class AlterTableEventAddEstTonage < ActiveRecord::Migration
  def up
    add_column :events, :estimated_tonage, :int
  end

  def down
    remove_column :events, :estimated_tonage
  end
end
