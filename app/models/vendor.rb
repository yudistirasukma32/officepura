class Vendor < ActiveRecord::Base

    has_many :containers
    has_many :vendorvehicles

    # Setup accessible (or protected) attributes for your model
    attr_accessible :deleted, :enabled, :event_id, :name, :npwp, :phone, :mobile,
                    :email, :description, :group, :user_id, :deleteuser_id
 
    scope :active, lambda {where(:deleted => false)}

end