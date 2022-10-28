class Assetpayment < ActiveRecord::Base
	belongs_to :assetorder

	has_many :bankexpenses

	# Setup accessible (or protected) attributes for your model
  	attr_accessible :deleted, :assetorder_id, :date, :total, :description, :user_id, :deleteuser_id

  	scope :active, lambda {where(:deleted => false)}  					

end
