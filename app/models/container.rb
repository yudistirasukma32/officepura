class Container < ActiveRecord::Base

	has_many :invoices
    has_many :officeexpenses

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :containernumber, :category

	scope :active, lambda {where(:enabled => true, :deleted => false)}  		
	
	validates :containernumber, uniqueness: true, presence: true

end
