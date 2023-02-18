class Vendorvehicle < ActiveRecord::Base

    belongs_to :vendor

    # Setup accessible (or protected) attributes for your model
    attr_accessible :deleted, :enabled, :current_id, :vendor_id, :year_made, :brand,
                    :color,:tire_amount, :description, :user_id, :deleteuser_id
 
    scope :active, lambda {where(:deleted => false)}

end