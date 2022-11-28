class AlterTableCommoditiesAddInsurance < ActiveRecord::Migration
  def up
    add_column :commodities, :insurance_amount, :money, :default => 0
  end

  def down
    remove_column :commodities, :insurance_amount
  end
end
