class Office < ActiveRecord::Base

	has_many :invoices
	has_many :users
	has_many :officeexpenses
	has_many :bankexpenses
	has_many :driverespenses
	has_many :payrolls

  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :enabled, :deleted, :name, :abbr, 
					:description,:latitude,:longitude,
					:address,:city,:province,:phone,
					:mobile,:garage

  	scope :active, lambda {where(:enabled => true, :deleted => false)}

	has_many :attachments, class_name: 'Attachment', :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

end
