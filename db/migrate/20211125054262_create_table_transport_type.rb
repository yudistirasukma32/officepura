class CreateTableTransportType < ActiveRecord::Migration
  def up

    add_column :routes, :transporttype, :string, :default => "TRUK"

    add_column :invoices, :transporttype, :string, :default => "TRUK"
    
  	create_table :transporttypes, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.boolean  	:enabled, :default => true
  		t.string		:name
  		t.timestamps
  	end

    default = Transporttype.new
    default.name = "TRUK"
    default.save
    default = Transporttype.new
    default.name = "ISOTANK"
    default.save
    default = Transporttype.new
    default.name = "KERETA"
    default.save
    default = Transporttype.new
    default.name = "KAPAL"
    default.save

    create_table :ships, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.boolean  	:enabled, :default => true
  		t.string		:name
      t.string		:imo
      t.string		:number
      t.string		:builder
      t.integer		:year_of_build
      t.text    	:description
  		t.timestamps
  	end

    create_table :ports, :force => true do |t|
  		t.boolean		:deleted, :default => false
  		t.boolean  	:enabled, :default => true
  		t.string		:name
      t.text    	:address
      t.string		:city
  		t.timestamps
  	end

  end

  def down
    remove_column :routes, :transporttype
    remove_column :invoices, :transporttype
    drop_table 	:transporttypes rescue nil
    drop_table 	:ships rescue nil
    drop_table 	:ports rescue nil
  end
end
