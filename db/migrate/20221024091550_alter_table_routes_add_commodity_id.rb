class AlterTableRoutesAddCommodityId < ActiveRecord::Migration
  def up
    add_column :routes, :commodity_id, :int
  end

  def down
    remove_column :routes, :commodity_id
  end
end
