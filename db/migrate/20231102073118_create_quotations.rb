class CreateQuotations < ActiveRecord::Migration
  def up
    create_table :quotations, :force => true do |t|
      t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
      t.string    :long_id
      t.date      :date
      t.date      :confirmed_date
      t.integer  	:customer_id
      t.string   	:name
      t.integer   :commodity_id
      t.integer   :office_id
      t.integer   :routegroup_id
      t.string    :transporttype
      t.integer  	:distance
			t.string   	:price_per_type
      t.timestamps
      t.string    :longitude_start
      t.string    :latitude_start
      t.string    :address_start
      t.string    :longitude_end
      t.string    :latitude_end
      t.string    :address_end
      t.string    :status
      t.integer   :created_by
      t.integer   :confirmed_by
      t.integer   :rejected_by
		end
    add_column :quotations, :price_per, :money, :default => 0

    create_table :quotationlogs, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
      t.integer   :quotation_id
      t.integer   :updated_by
			t.string   	:name
      t.text    	:description
			t.timestamps
		end
    add_column :quotationlogs, :old_price_per, :money, :default => 0
		add_column :quotationlogs, :new_price_per, :money, :default => 0

    add_column :routes, :quotation_id, :integer
  end

  def down
    remove_column :routes, :quotation_id
    drop_table :quotationlogs
    drop_table :quotations
  end
end
