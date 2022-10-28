class Productrequest < ActiveRecord::Base

	has_many :productrequestitems
	has_many :productorders
	has_many :bankexpenses

	belongs_to :driver
	belongs_to :vehicle
	belongs_to :productgroup

	attr_accessible :date, :driver_id, :vehicle_id, :description, :productgroup_id, :deleted

	scope :active, lambda {where(:deleted => false)}

end