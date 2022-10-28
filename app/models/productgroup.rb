class Productgroup < ActiveRecord::Base

	has_many :products
	has_many :tirebudgets

	attr_accessible :enabled, :name, :description, :deleted, :tire_flag

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
