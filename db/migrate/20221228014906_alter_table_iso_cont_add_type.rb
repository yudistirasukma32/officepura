class AlterTableIsoContAddType < ActiveRecord::Migration
  def up
    add_column :isotanks, :category, :string
    add_column :containers, :category, :string
  end

  def down
    remove_column :isotanks, :category
    remove_column :containers, :category
  end
end
