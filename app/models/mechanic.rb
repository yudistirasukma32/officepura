class Mechanic < ActiveRecord::Base

	has_many :mechaniclogs
	
	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :address, :city, :phone, :description
	
	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end