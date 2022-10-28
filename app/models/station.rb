class Station < ActiveRecord::Base

	has_many :origin_stations, class_name: 'Routetrain', foreign_key: 'origin_station_id'
	has_many :destination_stations, class_name: 'Routetrain', foreign_key: 'destination_station_id'
 
  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :enabled, :deleted, :name, :abbr, :description

  	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
