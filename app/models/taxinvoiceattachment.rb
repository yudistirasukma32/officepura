class Taxinvoiceattachment < ActiveRecord::Base
	# Setup accessible (or protected) attributes for your model
	attr_accessible :deleted, :enabled, :user_id, :taxinvoice_id, :customer_id, :date, :attachment_type,
	:upload, :description, :deleteuser_id

	scope :active, lambda {where(:deleted => false, :enabled => true)}

	belongs_to :customer
	belongs_to :taxinvoice
	belongs_to :user
	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end
end
