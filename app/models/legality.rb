class Legality < ActiveRecord::Base
  attr_accessible :description, :name, :number, :validity, :enabled, :deleted
	
	scope :active, lambda {where(:enabled => true, :deleted => false)}  	
	
	has_many :attachments, :as => :imageable
	
	def images
		attachments.where(:media => false).order(:id)
	end

	def documents
		attachments.where(:media => true).order(:id)
	end
	
end
