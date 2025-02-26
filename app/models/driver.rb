class Driver < ActiveRecord::Base
	after_create :setup_bankexpensegroup
	before_update :check_bankexpensegroup

	attr_accessor :old_name

	has_many :helpers
	has_many :invoices
	has_many :productrequests
	has_many :driverlogs
	has_many :driverexpenses
	has_many :payrolls

	belongs_to :vehicle
	belongs_to :vendor

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name,
					:address, :city, :phone, :mobile, :driver_licence, :driver_licence_expiry, :id_card, :id_card_expiry,
					:start_working, :description, :min_wages, :status, :salary, :terms_of_payment_in_days, :deleted, :emergency_number,
					:weight_loss, :accident, :sparepart, :bon, :saving, :vehicle_id, :bank_account, :bank_name, :bankexpensegroup_id, 
					:old_name, :origin, :is_resign, :vendor_id, :datein, :dateout,
					:blacklist, :blacklist_customer_id, :blacklist_note,
					:office_id

	scope :active, lambda {where(:enabled => true, :deleted => false, :blacklist => false).order(:name) }	
	scope :blacklisted, lambda {where(:enabled => true, :deleted => false, :blacklist => true).order(:name) }					

	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

  def setup_bankexpensegroup
	bankexpensegroup = Bankexpensegroup.create({
		name: "Bank Supir #{self.name}",
		bankexpensegroup_id: 137
	})
	self.save rescue nil
  end

  def check_bankexpensegroup
	if self.old_name.present? && self.name.present?
		if self.old_name != self.name && self.bankexpensegroup_id.present?
			bankexpensegroup = Bankexpensegroup.find(self.bankexpensegroup_id) rescue nil
			bankexpensegroup.name = "Bank Supir #{self.name}" rescue nil
			bankexpensegroup.bankexpensegroup_id = 137
			bankexpensegroup.save rescue nil
		end
	end
  end

end
