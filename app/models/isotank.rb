class Isotank < ActiveRecord::Base

	has_many :invoices
    has_many :officeexpenses

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :isotanknumber, :category, :group

	scope :active, lambda {where(:enabled => true, :deleted => false)}
	
	validates :isotanknumber, uniqueness: true, presence: true

end
