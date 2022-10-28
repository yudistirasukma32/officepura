class Office < ActiveRecord::Base

	has_many :invoices
	has_many :users
	has_many :officeexpenses
	has_many :bankexpenses
	has_many :driverespenses
	has_many :payrolls

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :enabled, :deleted, :name, :abbr, :description

  	scope :active, lambda {where(:enabled => true, :deleted => false)}

end
