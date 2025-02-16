class Quotationgroup < ActiveRecord::Base

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user },
	params: {
		customer_id: proc { |controller, model_instance| model_instance.customer_id },
		customer_pic: proc { |controller, model_instance| model_instance.customer_pic },
		description: proc { |controller, model_instance| model_instance.description },
		notes: proc { |controller, model_instance| model_instance.notes },
	}

	belongs_to :customer
	
	has_many :quotations
	has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :long_id, :date, :confirmed_date, :customer_id, :status, 
					:created_by, :confirmed_by, :rejected_by, :description, :total, :description, :notes, 
					:customer_name, :customer_pic, :customer_number, :customer_email,
					:reviewed, :reviewed_at, :reviewed_by, :confirmed, :confirmed_at, :is_sent, :sent_date, 
					:customer_approved, :customer_approved_date

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
