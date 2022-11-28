class Commodity < ActiveRecord::Base

	has_many :events
	has_many :eventmemos
	has_many :routes

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :description, :insurance_amount

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					
 
end
