class Routelocation < ActiveRecord::Base
  # attr_accessible :title, :body
	belongs_to :customer
	belongs_to :route
	
	attr_accessible :enabled, :deleted, :address_start, :customer_id, :route_id, :latitude_start, :longitude_start, :latitude_end, :longitude_end, :address_end
	
	scope :active, lambda {where(:enabled => true, :deleted => false)}  
	
end