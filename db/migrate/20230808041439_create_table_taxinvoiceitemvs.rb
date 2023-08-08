class CreateTableTaxinvoiceitemvs < ActiveRecord::Migration
  def up
    create_table :taxinvoiceitemvs, :force => true do |t|
      t.boolean 	:deleted, :default => false
      t.integer   :oriitem
      t.string  	:sku_id
      t.datetime 	:date
      t.string  	:vehicle_number
      t.integer 	:weight_gross, :default => 0
      t.integer  	:weight_net, :default => 0
      t.integer  	:event_id
      t.integer  	:customer_id
      t.integer  	:taxinvoice_id
      t.integer  	:office_id
      t.timestamps
      t.date      :load_date
      t.date      :unload_date
      t.boolean   :is_wholesale, :default => false
      t.boolean   :is_gross, :default => false
      t.boolean   :is_net, :default => false
      t.boolean   :rejected, :default => false
      t.string    :reject_reason
    end
    add_column :taxinvoiceitemvs, :price_per, :money, :default => 0
    add_column :taxinvoiceitemvs, :total, :money, :default => 0
    add_column :taxinvoiceitemvs, :wholesale_price, :money, :default => 0
  end

  def down
    drop_table :taxinvoiceitemvs
  end
end
