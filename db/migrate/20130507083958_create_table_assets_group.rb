class CreateTableAssetsGroup < ActiveRecord::Migration
  def up
  	create_table :assetgroups, :force => true do |t|
  		t.boolean	:deleted, :default => false
  		t.string  	:name
  		t.text		:description
  		t.float		:percent_decrease
  		t.timestamps
  	end

  	default = Assetgroup.new
  	default.name = "Bukan Bangunan 1"
  	default.description = "Bukan Bangunan Kelompok 1"
  	default.percent_decrease = 25
  	default.save
  	default = Assetgroup.new
  	default.name = "Bukan Bangunan 2"
  	default.description = "Bukan Bangunan Kelompok 2"
  	default.percent_decrease = 12.5
  	default.save
  	default = Assetgroup.new
  	default.name = "Bukan Bangunan 3"
  	default.description = "Bukan Bangunan Kelompok 3"
  	default.percent_decrease = 6.25
  	default.save
  	default = Assetgroup.new
  	default.name = "Bukan Bangunan 4"
  	default.description = "Bukan Bangunan Kelompok 4"
  	default.percent_decrease = 5
  	default.save
  	default = Assetgroup.new
  	default.name = "Bangunan Permanen"
  	default.description = "Bangunan Permanen"
  	default.percent_decrease = 5
  	default.save
  	default = Assetgroup.new
  	default.name = "Bangunan Tidak Permanen"
  	default.description = "Bangunan Tidak Permanen"
  	default.percent_decrease = 10
  	default.save

  	add_column :assets, :assetgroup_id, :integer
  end

  def down
  	drop_table :assetgroups
  end
end
