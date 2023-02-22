class Vendor < ActiveRecord::Base

    has_many :containers
    has_many :vendorvehicles
    has_many :events

    # Setup accessible (or protected) attributes for your model
    attr_accessible :deleted, :enabled, :event_id, :name, :npwp, :phone, :mobile,
                    :email, :description, :group, :user_id, :deleteuser_id, :abbr, :category

    validates :name, uniqueness: true, presence: true
 
    scope :active, lambda {where(:deleted => false)}

    scope :container, lambda {where(:group => 'Container')}

    scope :truck, lambda {where(:group => 'Truck')}

end