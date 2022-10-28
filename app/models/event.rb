class Event < ActiveRecord::Base

    belongs_to :customer
    belongs_to :office
    belongs_to :station
    belongs_to :user
    belongs_to :route
    belongs_to :commodity
    belongs_to :company
    
    has_many :invoices
    has_many :eventsalesorders
    has_many :eventvendors
    has_many :eventmemos

    attr_accessor :vendor, :pos

    # Setup accessible (or protected) attributes for your model
    attr_accessible :start_date, :end_date, :summary, :description, :customer_id,
    :deleted, :cancelled, :authorised, :authorised_dated, :payments_by, 
    :qty, :invoicetrain, :cargo_number, :cargo_type, :volume, :office_id, :pos_sby, :pos_smg, :pos_jkt, :pos_smt, :pos_lorry, 
    :vendor_name, :long_id, :station_id, :route_summary, :need_vendor, :user_id, :commodity_id, :route_id, :truck_quantity,
    :company_id, :estimated_tonage, :tanktype, :load_date, :unload_date

    scope :active, lambda {where(:deleted => false)}

    include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end