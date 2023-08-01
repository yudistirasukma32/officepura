class Invoice < ActiveRecord::Base

	belongs_to :driver
	belongs_to :vehicle, class_name: "Vehicle"
	belongs_to :customer
	belongs_to :route
	belongs_to :office
	belongs_to :invoice
	belongs_to :user
	belongs_to :isotank
	belongs_to :port
	belongs_to :ship
    belongs_to :container
    belongs_to :event
	belongs_to :routetrain
	belongs_to :operator
	belongs_to :operator, class_name: "Operator"
	belongs_to :shipoperator, class_name: "Operator"
	belongs_to :routeship
	belongs_to :vehicle_duplicate, class_name: "Vehicle"
	belongs_to :truckvendor, class_name: "Vendor"

	has_many :invoicereturns
	has_many :receipts
	has_many :receiptreturns
	has_many :taxinvoiceitems
	has_many :bonusreceipts
	has_many :receiptpremis
	has_many :invoices
	has_many :incentives
	has_many :trainexpenses
	has_many :shipexpenses
	has_many :mechaniclogs
	has_many :insuranceexpenses
	has_many :containerexpenses

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :date, :ship_name, :driver_id, :customer_id, :vehicle_id, :trip_type, :price_per, :gas_start,
  				:gas_litre, :gas_voucher, :gas_leftover, :ferry_fee, :tol_fee, :gas_cost, :insurance, :insurance_rate, :bonus, :incentive,
  				:quantity, :driver_allowance, :gas_allowance, :total, :description, :route_id, :vehiclegroup_id, :office_id, :deleted,
  				:invoice_id, :misc_allowance, :user_id, :helper_allowance, :need_helper, :deleteuser_id, :spk_number, :invoicetrain, :isotank_id, 
				:driver_phone, :transporttype, :port_id, :ship_id, :train_fee, :container_id, :tanktype, :isotank_number, :container_number, :event_id, 
				:premi, :premi_allowance, :routetrain_id, :operator_id, :shipoperator_id, :routeship_id, :invoicemultimode, :cargo_type, :losing,
				:vehicle_duplicate, :vehicle_duplicate_id, :weight_gross, :load_date, :is_insurance, :tsi_total, :by_vendor, :truckvendor_id,
				:kosongan, :kosongan_type, :kosongan_confirmed, :kosongan_confirmed_by, :kosongan_previous_invoice_id

  	def sum_gasleftover
  		self.gas_leftover * self.gas_cost
  	end

  	def check_phonedriver
  		# self.driver_phone = Invoice.drivers.mobile
  	end

  	scope :active, lambda {where(:enabled => true,:deleted => false)}

	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

	def thousand(number)
		extend ActionView::Helpers::NumberHelper
		number_with_delimiter(number, :delimiter => '.')
	end
	
	def get_tonage(offset, customer_35 = [])
		# offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		if (self.event.present? && event != 0)
			if (self.event.price_per_type == 'Borongan')
				tonage = "Borongan"
			else
				tonage = thousand(self.event.estimated_tonage.to_i)
			end
		elsif self.route.present?
			if (self.route.price_per || 0) >= offset 
				tonage = "Borongan"
			elsif customer_35.include? self.customer_id
				tonage = "35.000"
			elsif(self.invoicetrain && self.isotank_id.present? && self.route.price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage dibuat 20,000 kg 
				tonage = "20.000"
			elsif(self.office_id == 7)
				tonage = "30.000" #BKK Cargo Padat
			else
				tonage = "25.000"
			end

		else
			tonage = 0
		end

		return tonage
	end

	def get_estimation(offset, customer_35 = [])
		if customer_35.blank?
			customer_35 = []
		end
		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		route = self.route
		qty = self.quantity

		if (self.event.present? && event != 0)
			if (route.price_per || 0) >= offset
				estimation = qty * (route.price_per.to_i || 0)
			else
				estimation = qty * self.event.estimated_tonage.to_i * (route.price_per.to_i || 0)
			end
		elsif route.present?
			qty = self.quantity
			qty -= self.receiptreturns.where(:deleted => false).sum(:quantity) if self.receiptreturns.where(:deleted => false).any? 
			if (route.price_per || 0) >= offset 
				estimation = qty * (route.price_per.to_i || 0)
			elsif customer_35.include? self.customer_id
				estimation = qty * 35000 * (route.price_per.to_i || 0)
			elsif(self.invoicetrain && self.isotank_id.to_i != 0 && route.price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage dibuat 20,000 kg 
				estimation = qty * 20000 * (route.price_per.to_i || 0)
			elsif (self.office_id == 7)
				estimation = qty * 30000 * (route.price_per.to_i || 0)
			else
				estimation = qty * 25000 * (route.price_per.to_i || 0)
			end
		else
			estimation = 0
		end

		return estimation
	end

	def check_kosong_prod
		kosongan = Invoice.active.where(kosongan_previous_invoice_id: self.id)
		have_receipt = Receipt.active.where(invoice_id: self.id)
		if kosongan.blank? && have_receipt.present?
			return true
		else
			return false
		end
	end

end

# price_per > offset = qty * price_per
# invoicetrain.blank? & == 0 & price_per < offset
# 
