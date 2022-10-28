class Officeexpensegroup < ActiveRecord::Base

	has_many :officeexpenses
	has_many :receiptexpenses
	has_many :officeexpensegroups

	attr_accessible :enabled, :name, :description, :deleted, :officeexpensegroup_id

 	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
