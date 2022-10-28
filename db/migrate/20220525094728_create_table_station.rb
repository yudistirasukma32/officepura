class CreateTableStation < ActiveRecord::Migration
  def up
  	create_table :stations, :force => true do |t|
  		t.boolean   :deleted, :default => false
  		t.boolean  	:enabled, :default => true
  		t.string    :name
        t.string    :abbr
        t.string    :description
  		t.timestamps
  	end
      
    # Assign existing to default site
    default = Station.new
    default.name = "Kalimas"
    default.abbr = "KLM"
    default.save
    default = Station.new
    default.name = "Kampung Bandan"
    default.abbr = "KPB"
    default.save
    default = Station.new
    default.name = "Ronggowarsito"
    default.abbr = "RGW"
    default.save
      
  end

  def down
      drop_table    :stations rescue nil
  end
end
