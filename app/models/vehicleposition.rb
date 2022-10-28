class Vehicleposition < ActiveRecord::Base

	belongs_to :invoice
	belongs_to :vehicle
	belongs_to :driver
	belongs_to :route

	attr_accessible :enabled, :deleted, :date, :invoice_id, :vehicle_id, :driver_id, :route_id, :longitude, :latitude, :description, :status

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
