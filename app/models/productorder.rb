class Productorder < ActiveRecord::Base

	has_many :productorderitems
	has_many :receiptorders
	has_many :bankexpenses
	has_many :productorderitemreturns

	belongs_to :productrequest
	belongs_to :staff
	belongs_to :user

	attr_accessible :date, :description, :staff_id, :productrequest_id, :deleted, :user_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false)}
end