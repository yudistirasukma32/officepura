class Taxinvoice < ActiveRecord::Base
  include PublicActivity::Model

  # --- Activity Tracking ---
  tracked owner: Proc.new { |controller, model| controller.current_user },
          params: {
            sentdate:      proc { |_, model| model.sentdate },
            confirmeddate: proc { |_, model| model.confirmeddate }
          }

  # --- Associations ---
  belongs_to :customer
  belongs_to :office
  belongs_to :company
  belongs_to :user
  belongs_to :bank

  has_many :taxinvoiceitems
  has_many :taxinvoiceitemvs
  has_many :taxgenericitems
  has_many :taxinvoices
  has_many :customernotes, class_name: "Customernote", foreign_key: "customer_id"
  has_many :attachments, as: :imageable

  # --- Accessible Attributes ---
  attr_accessible :customer_id, :office_id, :date, :long_id, :ship_name, :description, :total, :deleted, :paiddate, :duedate,
                  :period_start, :period_end, :product_name, :spk_no, :po_no, :tank_name, :extra_cost, :extra_cost_info,
                  :total_in_words, :price_by, :is_weightlost, :spo_no, :sentdate, :so_no, :sto_no, :do_no, :confirmeddate,
                  :waybill, :remarks, :insurance_cost, :claim_cost, :company_id, :user_id, :generic, :gst_tax, :gst_percentage,
                  :price_tax, :bank_id, :booking_code, :secondpayment, :secondpayment_date, :is_showqty_loaded,
                  :is_showqty_unloaded, :is_dp, :dp_cost, :discount_percent, :discount_amount, :doubtful_ar,
                  :doubtful_ar_note, :is_show_container, :is_show_loadunload

  # --- Scopes ---
  scope :active, lambda { where(deleted: false) }

  # --- Validations ---
  # before_validation :normalize_long_id
  validates :long_id, presence: true, uniqueness: true

  # --- Instance Methods ---

  def images
    attachments.where(media: false).order('id DESC')
  end

  def get_ppn(default_ppn = 11)
    if (gst_tax > 0 && gst_percentage.to_f == 0) || (gst_percentage.to_f == default_ppn.to_f)
      default_ppn.to_f
    else
      gst_percentage.to_f
    end
  end

  # --- Class Methods ---

  def self.available_long_ids(month = Date.today.month, year = Date.today.year)
    month_year = sprintf('%02d-%d', month, year)
    rome = %w[I II III IV V VI VII VIII IX X XI XII][month - 1]

    sql = <<-SQL
      WITH existing AS (
        SELECT
          CAST(SUBSTRING(long_id FROM '^\\d{4}') AS INTEGER) AS number
        FROM taxinvoices
        WHERE TO_CHAR(date, 'MM-YYYY') = '#{month_year}'
        AND deleted = false
      ),
      series AS (
        SELECT generate_series(1, (SELECT COALESCE(MAX(number), 0) FROM existing)) AS number
      )
      SELECT
        LPAD(series.number::text, 4, '0') || ' / TGH / RDPI / #{rome} / #{year}' AS available_long_id
      FROM series
      WHERE series.number NOT IN (SELECT number FROM existing)
      ORDER BY series.number;
    SQL

    ActiveRecord::Base.connection.exec_query(sql).map { |r| r['available_long_id'] }
  end

  private

  def normalize_long_id
    return if long_id.blank?
    formatted = long_id.gsub(/\s*\/\s*/, ' / ').strip
    self.long_id = formatted
  end
end
