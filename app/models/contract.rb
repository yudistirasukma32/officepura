class Contract < ActiveRecord::Base

	belongs_to :customer
	has_many :routes
	
  	#Setup accessible (or protected) attributes for your model
	attr_accessible :name, :code, :date_start, :date_end, :customer_id, :contract_type, 
	:description, :enabled, :deleted, :total

	scope :active, lambda {where(:deleted => false)}

	has_many :attachments, class_name: 'Attachment', :as => :imageable

	def images
		attachments.where(:media => false).order(:id)
	end

	def documents
		attachments.where(:media => true).order(:id)
	end

end
