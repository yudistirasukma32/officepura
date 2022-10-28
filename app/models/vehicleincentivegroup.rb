class Vehicleincentivegroup < ActiveRecord::Base

	has_many :vehicles

	attr_accessible :enabled, :name, :description, :deleted, :incentive

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
