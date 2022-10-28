class Payroll < ActiveRecord::Base

	has_many :receiptpayrolls
	has_many :payrollreturns
	has_many :receiptpayrollreturns

	belongs_to :driver
	belongs_to :helper
	belongs_to :vehicle
	belongs_to :user
	belongs_to :office

	attr_accessible :deleted, :date, :period_start, :period_end, :driver_id, :helper_id, :vehicle_id, :holidays, :non_holidays, :user_id, 
					:deleteuser_id, :holidays_payment, :non_holidays_payment, :holidays_fare, :non_holidays_fare, :weight_loss, 
					:accident, :sparepart, :bon, :allowance, :saving, :saving_reduction,:total, :master_weight_loss, 
					:master_accident, :master_sparepart, :master_bon, :master_saving, :office_id, :bonus, :helper_fee

	scope :active, lambda {where(:deleted => false)}
end