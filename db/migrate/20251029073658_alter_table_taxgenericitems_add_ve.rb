class AlterTableTaxgenericitemsAddVe < ActiveRecord::Migration
  def up
    add_column :taxgenericitems, :vehicle_number, :string
    add_column :taxgenericitems, :container_number, :string
  end

  def down
    remove_column :taxgenericitems, :vehicle_number
    remove_column :taxgenericitems, :container_number
  end
end
