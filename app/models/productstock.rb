class Productstock < ActiveRecord::Base

	belongs_to :product

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :product_id, :quantity, :deleted
			
  	scope :active, lambda {where(:deleted => false)}
end