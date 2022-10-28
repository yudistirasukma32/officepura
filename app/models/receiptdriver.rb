class Receiptdriver < ActiveRecord::Base
	belongs_to :driverexpense

	belongs_to :user

	attr_accessible :deleted, :driverexpense_id, :total, :user_id, :deleteuser_id, :weight_loss, :accident, :sparepart, :bon, :saving

	scope :active, lambda {where(:deleted => false)}
end