class AddClaimmemos < ActiveRecord::Migration
  def up
    create_table :claimmemos, :force => true do |t|
      t.boolean :deleted, :default => false
      t.boolean :enabled, :default => true
      t.references :taxinvoiceitem, foreign_key: true, index: true
      t.references :invoice, foreign_key: true, index: true
      t.date      :date
      t.string  	:vehicle_number
      t.integer 	:weight_gross, :default => 0
      t.integer  	:weight_net, :default => 0
      t.integer  	:shrink, :default => 0
      t.text      :description
      t.timestamps
      t.integer   :user_id
      t.integer   :deleteuser_id
      t.boolean   :approved, :default => false
      t.boolean   :approved_by_gm, :default => false
      t.datetime  :approved_at
      t.datetime  :approved_by_gm_at

    end

    add_column :claimmemos, :shrink_tolerance_percent, :float, :default => 0.0
    add_column :claimmemos, :shrink_tolerance_money, :money, :default => 0
    add_column :claimmemos, :tolerance_total, :integer, :default => 0
    add_column :claimmemos, :shrinkage_load, :integer, :default => 0
    add_column :claimmemos, :price_per, :money, :default => 0
    add_column :claimmemos, :total, :money, :default => 0
  end

  def down
    remove_column :claimmemos, :total
    remove_column :claimmemos, :price_per
    remove_column :claimmemos, :shrinkage_load
    remove_column :claimmemos, :tolerance_total
    remove_column :claimmemos, :shrink_tolerance_money
    remove_column :claimmemos, :shrink_tolerance_percent
    drop_table :claimmemos
  end
end
