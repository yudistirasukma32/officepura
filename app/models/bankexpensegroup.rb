class Bankexpensegroup < ActiveRecord::Base

	has_many :bankexpenses
	has_many :bankexpensegroups

	attr_accessible :enabled, :name, :description, :deleted, :total, :inreport,:bankexpensegroup_id

 	scope :active, lambda {where(:enabled => true, :deleted => false)}
 	scope :parentgroup, lambda {where(:bankexpensegroup_id => nil)}
 	scope :childgroup, lambda {where.not(:bankexpensegroup_id => nil)}
end
