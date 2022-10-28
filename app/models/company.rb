class Company < ActiveRecord::Base

	has_many :events
    has_many :taxinvoices

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :abbr, :description

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
