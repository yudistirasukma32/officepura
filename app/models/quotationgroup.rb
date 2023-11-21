class Quotationgroup < ActiveRecord::Base

	belongs_to :customer

	has_many :quotations

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :long_id, :date, :confirmed_date, :customer_id, :status, :created_by, :confirmed_by, :rejected_by, :description, :total, :description, :notes, :customer_name, :customer_pic, :customer_number, :customer_email

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
