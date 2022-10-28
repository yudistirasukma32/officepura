class AlterTableBonusreceipts < ActiveRecord::Migration
  def up
  	add_column :bonusreceipts, :load_location, :text
  	add_column :bonusreceipts, :load_date, :date 
  	add_column :bonusreceipts, :load_hour, :text
  	add_column :bonusreceipts, :unload_location, :text
  	add_column :bonusreceipts, :unload_date, :date 
  	add_column :bonusreceipts, :unload_hour, :text
  end

  def down
  	remove_column :bonusreceipts, :load_location
  	remove_column :bonusreceipts, :load_date
  	remove_column :bonusreceipts, :load_hour
  	remove_column :bonusreceipts, :unload_location
  	remove_column :bonusreceipts, :unload_date
  	remove_column :bonusreceipts, :unload_hour
  end
end
