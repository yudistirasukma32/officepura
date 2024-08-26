class Receipttaxinvitem < ActiveRecord::Base
	belongs_to :user

	# Setup accessible (or protected) attributes for your model
	attr_accessible :deleted, :enabled, :printdate, :user_id, :printuser_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false, :enabled => true)}

	has_many :taxinvoiceitems
end
