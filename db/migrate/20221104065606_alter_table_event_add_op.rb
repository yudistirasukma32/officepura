class AlterTableEventAddOp < ActiveRecord::Migration
  def up
    add_column :events, :operator_id, :int
    add_column :events, :routetrain_id, :int
    add_column :eventmemos, :platform_type, :string
  end

  def down
    remove_column :events, :operator_id
    remove_column :events, :routetrain_id
    remove_column :eventmemos, :platform_type
  end
end
