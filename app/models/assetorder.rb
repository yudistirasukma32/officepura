class Assetorder < ActiveRecord::Base
	belongs_to :asset

	has_many :assetpayments
	has_many :bankexpenses
	
	# Setup accessible (or protected) attributes for your model
  	attr_accessible :deleted, :asset_id, :date, :quantity, :unit_name, :unit_price, :total, :description, :user_id, :deleteuser_id

  	scope :active, lambda {where(:deleted => false)}  					

end
