class Driver < ActiveRecord::Base

	has_many :helpers
	has_many :invoices
	has_many :productrequests
	has_many :driverlogs
	has_many :driverexpenses
	has_many :payrolls

	belongs_to :vehicle

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name,
					:address, :city, :phone, :mobile, :driver_licence, :driver_licence_expiry, :id_card, :id_card_expiry,
					:start_working, :description, :min_wages, :status, :salary, :terms_of_payment_in_days, :deleted, :emergency_number,
					:weight_loss, :accident, :sparepart, :bon, :saving, :vehicle_id, :bank_account

  scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
