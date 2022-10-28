class Receiptpayrollreturn < ActiveRecord::Base

	belongs_to :payroll
	belongs_to :user

	attr_accessible :deleted, :payroll_id, :user_id, :deleteuser_id, :holidays_payment, :non_holidays_payment, 
					:weight_loss, :accident, :sparepart, :bon, :allowance, :saving, :saving_reduction, :total, :bonus

	scope :active, lambda {where(:deleted => false)}
end