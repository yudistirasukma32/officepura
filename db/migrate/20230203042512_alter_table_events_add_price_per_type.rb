class AlterTableEventsAddPricePerType < ActiveRecord::Migration
  def up
    add_column :events, :price_per_type, :string
  end

  def down
    remove_column :events, :price_per_type
  end
end
