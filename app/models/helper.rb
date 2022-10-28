class Helper < ActiveRecord::Base

  belongs_to :driver
  has_many :payrolls
  has_many :driverexpenses

  # Setup accessible (or protected) attributes for your model
  attr_accessible :enabled, :name,
					:address, :city, :phone, :mobile, :driver_licence, :driver_licence_expiry, :id_card, :id_card_expiry,
					:description, :salary, :driver_id,  :emergency_number,
					:weight_loss, :accident, :sparepart, :bon,  :saving

  scope :active, lambda {where(:enabled => true, :deleted => false)} 
end
