class CreateTaxGenericInvoiceItems < ActiveRecord::Migration
  def up
  	add_column :taxinvoices, :generic, :boolean, :default => false
    add_column :vehicles, :generic, :boolean, :default => false

    create_table :taxgenericitems, :force => true do |t|
      t.boolean :deleted, :default => false
      t.integer :taxinvoice_id
      t.integer :customer_id
      t.integer :office_id
      t.integer :vehicle_id
      t.string 	:sku_id
      t.string 	:description
      t.date    :date
      t.date    :load_date
      t.date    :unload_date
      t.integer :weight_gross, :default => 0
      t.integer :weight_net, :default => 0
      t.integer :deleteuser_id

      t.timestamps
    end  	

  	add_column :taxgenericitems, :price_per, :money, :default => 0
  	add_column :taxgenericitems, :total, :money, :default => 0
  end

  def down
  	drop_table 	:taxgenericitems
  end
end
