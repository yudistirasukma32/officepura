class Container < ActiveRecord::Base

	has_many :invoices
    has_many :officeexpenses

	belongs_to :vendor

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :containernumber, :category, :vendor_id

	scope :active, lambda {where(:enabled => true, :deleted => false)}  		
	
	validates :containernumber, uniqueness: true, presence: true

end
