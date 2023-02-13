class Staff < ActiveRecord::Base

  # Setup accessible (or protected) attributes for your model
  has_many :productorders
  has_many :users

  attr_accessible :enabled, :name, :email,
					:address, :city, :phone, :mobile, :driver_licence, :driver_licence_expiry, :id_card, :id_card_expiry,
					:start_working, :description, :min_wages, :status, :salary, :terms_of_payment_in_days, :deleted, :office_id,
          :family_card_number, :family_status, :emergency_contact, :origin
          
  scope :active, lambda {where(:enabled => true, :deleted => false)}  					

end
