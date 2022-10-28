class Receiptorder < ActiveRecord::Base

	belongs_to :productorder
	belongs_to :user

	attr_accessible :productorder_id, :date, :total, :bon, :deleted, :user_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false)}
end