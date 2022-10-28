class Vehiclegroup < ActiveRecord::Base

	has_many :allowances
	has_many :vehicles

	attr_accessible :enabled, :name, :description, :deleted

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
