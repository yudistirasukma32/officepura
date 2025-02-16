class Customer < ActiveRecord::Base

	has_many :routes
	has_many :invoices
	has_many :taxinvoices
	has_many :taxinvoiceitems
	has_many :taxinvoiceitemvs
	has_many :events

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :name, :address, :city, :contact, :phone, :mobile, :fax, :email,
					:npwp, :description, :terms_of_payment_in_days, :wholesale_price, :deleted,
					:email_alt, :load_hour, :unload_hour, :phone2, :phone3, :mobile2, :mobile3,
					:province, :gst_percentage, :price_tax, :rating,
					:price_by, :is_weightlost, :is_showqty_loaded, :is_showqty_unloaded, :is_rounded,
					:bank_id, :memo, :memo_attachments, :memo_info, :memo_address,
					:dp, :dp_notes, :ktp_photo, :npwp_photo, :pic_photo, :approved

	scope :active, lambda {where(:enabled => true, :deleted => false)}
	scope :unverified, -> { where(approved: false).order(name: :asc) }

	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
