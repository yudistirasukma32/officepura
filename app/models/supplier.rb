class Supplier < ActiveRecord::Base

	has_many :productorderitems
	has_many :supplierpayments
	has_many :paymentchecks
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name,
  					:address, :city, :contact, :phone, :mobile, :fax, :npwp, :description, :terms_of_payment_in_days, :deleted

  scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
