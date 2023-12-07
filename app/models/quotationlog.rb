class Quotationlog < ActiveRecord::Base

	belongs_to :Quotation

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :name, :quotation_id, :updated_by, :old_price_per, :new_price_per

	scope :active, lambda {where(:enabled => true, :deleted => false)}  					

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
