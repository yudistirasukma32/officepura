class Vehicle < ActiveRecord::Base

	belongs_to :vehiclegroup
	belongs_to :vehicleincentivegroup
    belongs_to :office

	has_many :invoices
	has_many :vehiclelogs
	has_many :productrequests
	has_many :payrolls
	has_many :drivers
	has_many :tirebudgets
	has_many :vehicle_duplicates, class_name: 'Invoice', foreign_key: 'vehicle_duplicate_id'
	
	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :current_id, :previous_id, :id_expiry,
						:registration, :vehicle_type, :year_made, :tank_capacity, :gas_capacity, :gas_leftover,
						:tire_size, :barcode, :next_checkup_date, :next_registration_date, :next_tax_date, :next_tera_date,
					:machine_serial, :skel_bar_serial, :skel_bar_serial_2, :next_checkup_date_second,
					:description, :vehiclegroup_id, :deleted, :date_purchase, :amount, :tank_type, :siup, :tire_target, :plat_type,
					:vehicleincentivegroup_id, :office_id, :platform_type, :gps_number, :bpkb_number, :owner_name, 
					:owner_address, :brand, :color, :tire_amount, :user_id, :updated, :old_data

	scope :active, lambda {where(:enabled => true, :deleted => false)}
	
	# validates :current_id, uniqueness: true, presence: true
  
	has_many :attachments, :as => :imageable

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }
	tracked :params => {
		:vehiclegroup_id => proc {|controller, model_instance| model_instance.vehiclegroup.name},
		:office_id => proc {|controller, model_instance| model_instance.office.name},
		:platform_type => proc {|controller, model_instance| model_instance.platform_type},
		:updated_by => proc {|controller, model| controller.current_user.username}
	}

	def images
		attachments.where(:media => false).order(:id)
	end

	def documents
		attachments.where(:media => true).order(:id)
	end

end
