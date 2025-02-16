class UpdateClaimmemo < ActiveRecord::Migration
  def up
    add_column :claimmemos, :discount_amount, :money, :default => 0
    add_column :claimmemos, :is_train, :boolean, :default => false
    add_column :claimmemos, :approved_marketing, :boolean, :default => false
    add_column :claimmemos, :approved_load_spv, :boolean, :default => false
    add_column :claimmemos, :approved_unload_spv, :boolean, :default => false
  end

  def down
    remove_column :claimmemos, :discount_amount
    remove_column :claimmemos, :is_train
    remove_column :claimmemos, :approved_marketing
    remove_column :claimmemos, :approved_load_spv
    remove_column :claimmemos, :approved_unload_spv
  end
end