class Driverexpense < ActiveRecord::Base
	has_many :receiptdrivers

	belongs_to :driver
	belongs_to :helper
	belongs_to :office

	attr_accessible :deleted, :date, :description, :driver_id, :helper_id, :total, :office_id, :user_id, :deleteuser_id, :weight_loss, :accident, :sparepart,
					:bon, :saving

	scope :active, lambda {where(:deleted => false)}
end