class Routegroup < ActiveRecord::Base

	has_many :routes

	attr_accessible :enabled, :name, :description, :deleted

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
