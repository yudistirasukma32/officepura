class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body 
	has_many :userroles

	has_many :receipts
	has_many :receiptreturns
	has_many :receiptexpenses
	has_many :receiptpremis
	has_many :receiptorders
	has_many :receiptsales
	has_many :invoices
	has_many :invoicereturns
	has_many :bonusreceipts
	has_many :productorders
	has_many :payrolls
	has_many :receiptpayrolls
	has_many :payrollreturns
	has_many :receiptpayrollreturns
	has_many :receiptdrivers
	has_many :events
	has_many :taxinvoiceitems

	belongs_to :office
	belongs_to :staff
  	
  	# Setup accessible (or protected) attributes for your model
  	attr_accessible :enabled, :username, :password, :role, :count_login, :last_login, :deleted, :office_id, :staff_id, :adminrole, :owner

  	scope :active, lambda {where(:enabled => true, :deleted => false)}

	def active_for_authentication?
		super && !deleted
	end

end
