class Insurancevendor < ActiveRecord::Base

	has_many :insuranceexpenses

	# Setup accessible (or protected) attributes for your model
	attr_accessible :enabled, :deleted, :name, :pic, :mobile, :phone, :description, :bank_name, :bank_account, :terms_of_payment_in_days

	scope :active, lambda {where(:enabled => true, :deleted => false)}
	
	validates :name, uniqueness: true, presence: true

end
