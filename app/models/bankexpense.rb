class Bankexpense < ActiveRecord::Base

	belongs_to :bankexpensegroup
	belongs_to :vehicle
	belongs_to :office
	belongs_to :taxinvoice
	belongs_to :productorder
	belongs_to :productrequest
	belongs_to :assetorder
	belongs_to :assetpayment

	belongs_to :bankexpense
	belongs_to :bankinvoice
	belongs_to :claimmemo

	has_many :bankexpenses

	attr_accessible :enabled, :deleted, :date, :description, :debitgroup_id, :creditgroup_id, :taxinvoice_id, :total, :office_id, :deleteuser_id, :bankexpense_id, :productrequest_id, 
					:assetorder_id, :assetpayment_id, :money_in, :bankledger, :pettycashledger, :claimmemo_id

  scope :active, lambda {where(:enabled => true, :deleted => false)}

	include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
