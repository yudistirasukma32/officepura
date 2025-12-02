class Receipttaxinvoice < ActiveRecord::Base
	scope :active, lambda {where(:deleted => false, :enabled => true)}

	belongs_to :user
	has_many :taxinvoices
    
	attr_accessible :deleted,
                :enabled,
                :printdate,
                :user_id,
                :printuser_id,
                :deleteuser_id,
                :billing_date,
                :date,
                :taxinvoice_list

end
