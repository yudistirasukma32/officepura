class AddColumnIndustryToCommodity < ActiveRecord::Migration
  def up
    change_table  :commodities do |t|
      t.string :industry
    end
  end

  def down
    change_table :commodities do |t|
      t.remove :industry
    end
  end
end
