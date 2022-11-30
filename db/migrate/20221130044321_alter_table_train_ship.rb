class AlterTableTrainShip < ActiveRecord::Migration
  def up
    add_column :trainexpenses, :misc_total, :money, :default => 0
    add_column :receipttrains, :misc_total, :money, :default => 0
    add_column :shipexpenses, :misc_total, :money, :default => 0
    add_column :receiptships, :misc_total, :money, :default => 0
  end

  def down
    remove_column :trainexpenses, :misc_total
    remove_column :receipttrains, :misc_total
    remove_column :shipexpenses, :misc_total
    remove_column :receiptships, :misc_total

  end
end
