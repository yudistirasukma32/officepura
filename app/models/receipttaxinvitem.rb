class Receipttaxinvitem < ActiveRecord::Base
	
	belongs_to :user
	has_many :taxinvoiceitems

	# Setup accessible (or protected) attributes for your model
	attr_accessible :deleted, :enabled, :printdate, :user_id, :printuser_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false, :enabled => true)}

end
