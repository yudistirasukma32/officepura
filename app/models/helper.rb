class Helper < ActiveRecord::Base

  belongs_to :driver
  has_many :payrolls
  has_many :driverexpenses

  has_many :attachments, :as => :imageable

	def images
		attachments.where(:media => false).order('id DESC')
	end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name,
                  :address, :city, :phone, :mobile, :driver_licence, :driver_licence_expiry, 
                  :id_card, :id_card_expiry,
                  :description, :salary, :driver_id,  :emergency_number,
                  :weight_loss, :accident, :sparepart, :bon,  :saving,
                  :deleted,  
                  :bank_account, :bank_name, :bankexpensegroup_id, :old_name, :origin, :is_resign,  
                  :vendor_id, :datein, :dateout, :blacklist, :blacklist_customer_id, :blacklist_note,
                  :office_id

  scope :active, lambda {where(:enabled => true, :deleted => false, :blacklist => false).order(:name) }	
  scope :blacklisted, lambda {where(:enabled => true, :deleted => false, :blacklist => true).order(:name) }					

  has_many :attachments, :as => :imageable

  def images
    attachments.where(:media => false).order('id DESC')
  end

end
