class AlterTableProductorderitemreturs < ActiveRecord::Migration
  def up
  	add_column :productorderitemreturns, :date, :date
  	add_column :productorderitemreturns, :description, :text
  end

  def down
  end
end
