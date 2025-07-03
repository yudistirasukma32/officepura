class Bank < ActiveRecord::Base

	has_many :taxinvoices
	has_many :customers

  # Setup accessible (or protected) attributes for your model
  	attr_accessible :name, :bank_account_name, :bank_account_number, :note, :enabled, :deleted

  	scope :active, lambda {where(:deleted => false)}

end