class Event < ActiveRecord::Base

    belongs_to :customer
    belongs_to :office
    belongs_to :station
    belongs_to :user
    belongs_to :route
    belongs_to :commodity
    belongs_to :company
    belongs_to :routetrain
    belongs_to :routeship
	belongs_to :operator
    belongs_to :vendor

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
    :company_id, :estimated_tonage, :tanktype, :load_date, :unload_date, :routetrain_id, :operator_id,
    :downpayment_amount, :downpayment_date, :losing, :price_per_type, :invoiceship, :routeship_id, :is_stapel,
    :invoice_count, :invoiceconfirmed_count, :invoice_taxitems_count, :invoice_taxinv_count,
    :is_insurance, :tsi_total,
    :load_province, :unload_province,
    :deleteuser_id, :multicontainer, :unload_vendor, :reject_reason

    scope :active, lambda {where(:deleted => false)}

    include PublicActivity::Model
	tracked owner: Proc.new { |controller, model| controller.current_user }

end
