class CreateMasters < ActiveRecord::Migration
  def up

		create_table :users, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:username
			t.string   	:password
			t.string   	:role
			t.integer  	:count_login
			t.datetime	:last_login
			t.integer 	:office_id
			t.integer 	:staff_id
			t.boolean		:adminrole, :default => false
			t.timestamps
		end

		create_table :userroles, :force => true do |t|
			t.integer  	:user_id
			t.integer 	:role_id
			t.timestamps
		end 

		create_table :roles, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean 	:enabled, :default => true
			t.string 	:name
			t.text 		:description
			t.timestamps
		end

	  	default = Role.new
	  	default.name = "Akuntan"
	  	default.save
	  	default = Role.new
	  	default.name = "Operasional"
	  	default.save
	  	default = Role.new
	  	default.name = "Inventori"
	  	default.save
	  	default = Role.new
	  	default.name = "Premi"
	  	default.save
	  	default = Role.new
	  	default.name = "Kasir"
	  	default.save 

		create_table :customers, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.string   	:address
			t.string   	:city
			t.string   	:contact
			t.string   	:phone
			t.string   	:mobile
			t.string   	:fax
			t.string   	:npwp
			t.integer  	:terms_of_payment_in_days
			t.text   		:description
			t.timestamps
		end
  	
		create_table :suppliers, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.string   	:address
			t.string   	:city
			t.string   	:contact
			t.string   	:phone
			t.string   	:mobile
			t.string   	:fax
			t.string   	:npwp
			t.integer  	:terms_of_payment_in_days
			t.text  		:description
			t.timestamps
		end

		create_table :staffs, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:email
			t.string   	:name
			t.string   	:address
			t.string   	:city
			t.string   	:phone
			t.string   	:mobile
			t.string   	:driver_licence
			t.datetime	:driver_licence_expiry
			t.string   	:id_card
			t.datetime	:id_card_expiry
			t.datetime	:start_working
			t.integer   :salary
			t.integer  	:terms_of_payment_in_days
			t.integer   :min_wages
			t.string 	:status
			t.text    	:description
			t.timestamps
		end

		create_table :drivers, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.string   	:address
			t.string   	:city
			t.string   	:phone
			t.string   	:mobile
			t.string   	:driver_licence
			t.datetime	:driver_licence_expiry
			t.string   	:id_card
			t.datetime	:id_card_expiry
			t.datetime	:start_working
			t.integer   :salary
			t.integer  	:terms_of_payment_in_days
			t.integer   :min_wages
			t.string 		:status
			t.text    	:description
			t.timestamps
		end

		create_table :helpers, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.string   	:address
			t.string   	:city
			t.string   	:phone
			t.string   	:mobile
			t.string   	:driver_licence
			t.datetime	:driver_licence_expiry
			t.string   	:id_card
			t.datetime	:id_card_expiry
			t.integer   :salary
			t.text    	:description
			t.integer  	:driver_id
			t.timestamps
		end

		create_table :products, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.boolean 	:archive, :default=>false
			t.string   	:name
			t.string   	:sku
			t.string   	:barcode
			t.string   	:unit_name
			t.string   	:discount_percent
			t.string   	:status
			t.integer   :distance
			t.text    	:description
			t.integer  	:warehouse_id
			t.integer 	:stock, :default => 0
			t.integer   :productgroup_id
			t.timestamps
		end		
		
		add_column :products, :unit_price, :money, :default => 0
		add_column :products, :discount_price, :money

		create_table :productgroups, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.text    	:description
			t.timestamps
		end		

		create_table :warehouses, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.string   	:address
			t.string   	:city
			t.string   	:phone
			t.text   		:description
			t.timestamps
		end

		create_table :routes, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.integer  	:distance
			t.string   	:price_per_type
			t.string   	:item_type
			t.text    	:description
			t.integer  	:customer_id
			t.integer		:routegroup_id
			t.timestamps
		end
		add_column :routes, :bonus, :money, :default => 0
		add_column :routes, :tol_fee, :money, :default => 0
		add_column :routes, :ferry_fee, :money, :default => 0
		add_column :routes, :price_per, :money, :default => 0

		create_table :routegroups, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.text    	:description
			t.timestamps
		end

	    # Assign existing to default site
	    default = Routegroup.new
	    default.name = "PP Kosongan"
	    default.save
	    default = Routegroup.new
	    default.name = "Non PP Isi"
	    default.save
	    default = Routegroup.new
	    default.name = "Non PP Kosongan"
	    default.save		
	
		create_table :allowances, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.integer  	:route_id
			t.integer  	:vehiclegroup_id
			t.integer  	:gas_trip, :default => 0
			t.timestamps
		end
		add_column :allowances, :driver_trip, :money, :default => 0

		create_table :vehicles, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:current_id
			t.string   	:previous_id
			t.datetime 	:id_expiry
			t.string  	:registration
			t.string  	:vehicle_type
			t.string  	:year_made
			t.integer 	:tank_capacity
			t.integer 	:gas_capacity
			t.integer		:gas_leftover, :default => 0
			t.string 		:tire_size
			t.datetime 	:next_checkup_date
			t.datetime 	:next_registration_date
			t.datetime 	:next_tax_date
			t.string   	:machine_serial
			t.string   	:skel_bar_serial
			t.string   	:skel_bar_serial_2
			t.string   	:barcode
			t.text   		:description
			t.integer   :vehiclegroup_id
			t.timestamps
		end

		create_table :vehiclelogs, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.boolean  	:ready, :default => false
			t.boolean  	:broken, :default => false
			t.integer  	:vehicle_id
			t.text   	:description
			t.timestamps
		end

		create_table :vehiclegroups, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.text    	:description
			t.timestamps
		end		

	    # Assign existing to default site
	    default = Vehiclegroup.new
	    default.name = "SIL 6"
	    default.save
	    default = Vehiclegroup.new
	    default.name = "SIL 8"
	    default.save
	    default = Vehiclegroup.new
	    default.name = "LOKAL"
	    default.save

	    create_table :driverlogs, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.boolean  	:ready, :default => false
			t.boolean  	:absent, :default => false
			t.integer  	:driver_id
			t.text   	:description
			t.timestamps
		end

		create_table :events, :force => true do |t|
			t.boolean :deleted, :default => false
			t.date		:start_date
			t.date  	:end_date
			t.string 	:summary
			t.text		:description
			t.timestamps
		end

		create_table :assets, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.datetime  :date_purchase
			t.string   	:amount_type
			t.integer  	:quantity
			t.string   	:asset_type
			t.text   		:description
			t.timestamps
		end		
		add_column :assets, :amount, :money, :default => 0

		create_table :offices, :force => true do |t|
			t.boolean 	:deleted, :default => false
			t.boolean  	:enabled, :default => true
			t.string   	:name
			t.string   	:abbr
			t.text   	:description
			t.timestamps
		end		

	    default = Office.new
	    default.name = "Surabaya"
	    default.abbr = "SUB"
	    default.save
	    default = Office.new
	    default.name = "Jakarta"
	    default.abbr = "JKT"
	    default.save
	    default = Office.new
	    default.name = "Probolinggo"
	    default.abbr = "PRB"
	    default.save

		create_table :settings, :force => true do |t|
			t.boolean 	:editable, :default => true
			t.boolean  	:enabled, :default => true
			t.string  	:group
			t.string  	:name
			t.string  	:value
			t.text    	:description
			t.timestamps
		end

	    default = Setting.new
	    default.name = "Harga Solar"
	    default.description = "Harga Solar dalam Rupiah"
	    default.value = "4500"
	    default.save
	    default = Setting.new
	    default.name = "Rate Asuransi"
	    default.description = "Rate Asuransi BKK untuk total Tanggungan (contoh: 0.75)"
	    default.value = "0.095"
	    default.save
	    default = Setting.new
	    default.name = "Saldo Kas Kantor"
	    default.description = "Saldo Jalan untuk Kas Kantor"
	    default.value = "0"
	    default.save
	    default = Setting.new
	    default.name = "Budget Pembelian"
	    default.description = "Budget untuk pembelian barang"
	    default.value = "50000000"
	    default.save
	    default = Setting.new
	    default.name = "Client Name"
	    default.description = "Name Perusahaan pengguna aplikasi"
	    default.value = "PT. Putra Rajawali Trans"
	    default.save
	    default = Setting.new
	    default.name = "Client Address"
	    default.description = "Alamat Perusahaan pengguna aplikasi"
	    default.value = "Surabaya"
	    default.save

	  	create_table :attachments, :force => true do |t|
	       t.boolean  :enabled, :default => true
	       t.string   :name
	       t.string   :file_uid
	       t.string   :file_name
	       t.boolean  :media
	       t.integer  :imageable_id
	       t.string   :imageable_type
	       t.timestamps    
	     end 
  end

  def down
  	drop_table 	:users,
				:customers,
				:suppliers,
				:staffs,
				:drivers,
				:helpers,
				:products,
				:productgroups,
				:routes,
				:vehicles,
				:vehiclegroups,
				:vehiclelogs,
				:driverlogs,
				:events,
				:warehouses,
				:offices,
				:settings,
				:attachments
				
  end
end
