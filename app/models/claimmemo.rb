class Claimmemo < ActiveRecord::Base

  belongs_to :taxinvoiceitem
  belongs_to :invoice
  belongs_to :user

  has_many :bankexpenses

  # Setup accessible (or protected) attributes for your model
  attr_accessible :deleted, :enabled, :invoice_id, :taxinvoiceitem_id,
                  :date, :vehicle_number, :weight_gross, :weight_net, :shrink,
                  :description, :user_id, :deleteuser_id, :approved, :approved_by_gm,
                  :approved_at, :approved_by_gm_at, 
                  :shrink_tolerance_percent, :shrink_tolerance_money,
                  :price_per, :total, :shrinkage_load, :tolerance_total,
                  :discount_amount, :is_train, 
                  :approved_marketing, :approved_load_spv, :approved_unload_spv,
                  :driver_charge, :claim_letter

  scope :active, lambda {where(:deleted => false)}

  has_many :attachments, :as => :imageable

  def images
	  attachments.where(:media => false).order('id DESC')
  end

end
