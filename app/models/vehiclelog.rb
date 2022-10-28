class Vehiclelog < ActiveRecord::Base

	belongs_to :vehicle

	attr_accessible :enabled, :deleted, :ready, :broken, :description, :vehicle_id

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
