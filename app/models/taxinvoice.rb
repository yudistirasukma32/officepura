class Taxinvoice < ActiveRecord::Base

	belongs_to :customer
	belongs_to :office
	belongs_to :company
	belongs_to :user
	belongs_to :bank

	has_many :taxinvoiceitems
	has_many :taxinvoiceitemvs
	has_many :taxgenericitems
	has_many :taxinvoices

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :customer_id, :office_id, :date, :long_id, :ship_name, :description, :total, :deleted, :paiddate, :duedate, :period_start, :period_end, :product_name, 
  					:spk_no, :po_no, :tank_name, :extra_cost, :extra_cost_info, :total_in_words, :price_by, :is_weightlost, 
					:spo_no, :sentdate, :so_no, :sto_no, :do_no, :confirmeddate, :waybill, :remarks, :insurance_cost, :claim_cost, :company_id, :user_id,
					:generic, :gst_tax, :gst_percentage, :price_tax, :bank_id, :booking_code,
					:secondpayment, :secondpayment_date

  	scope :active, lambda {where(:deleted => false)}

	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

	def get_ppn default_ppn = 11
		
		if (self.gst_tax > 0 && self.gst_percentage.to_f == 0) || (self.gst_percentage.to_f == default_ppn.to_f)
			ppn_percentage = default_ppn.to_f
		else
			ppn_percentage = self.gst_percentage.to_f							
		end

		return ppn_percentage
	end
end
