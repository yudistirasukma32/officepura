class Driverlog < ActiveRecord::Base

	belongs_to :driver

	attr_accessible :enabled, :deleted, :ready, :absent, :description, :driver_id

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end