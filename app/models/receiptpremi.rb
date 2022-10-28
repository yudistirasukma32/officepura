class Receiptpremi < ActiveRecord::Base

	belongs_to :invoice
	belongs_to :bonusreceipt
	belongs_to :user

	attr_accessible :invoice_id, :total, :date, :deleted, :user_id, :deleteuser_id

	scope :active, lambda {where(:deleted => false)}
end