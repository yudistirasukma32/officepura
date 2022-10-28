class Operator < ActiveRecord::Base

	has_many :routetrains
	has_many :trainexpenses
	has_many :invoices

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :abbr, :description

	scope :active, lambda {where(:enabled => true, :deleted => false)}
	
	validates :name, uniqueness: true, presence: true

end
