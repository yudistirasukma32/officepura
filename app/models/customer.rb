class Customer < ActiveRecord::Base

	has_many :routes
	has_many :invoices
	has_many :taxinvoices
	has_many :taxinvoiceitems
	has_many :events

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :name, :address, :city, :contact, :phone, :mobile, :fax, :email,
					:npwp, :description, :terms_of_payment_in_days, :wholesale_price, :deleted, 
					:email_alt, :load_hour, :unload_hour

	scope :active, lambda {where(:enabled => true, :deleted => false)}  		

	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
