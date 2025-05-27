class InsuranceexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "insuranceexpenses"
    @where = "insuranceexpenses"
  end

  def set_role
    @user_role = 'Admin Keuangan, Admin Operasional, Admin Asuransi'
  end

  def index_old

    role = cek_roles @user_role
    if role
     
      @where = "insuranceexpenses"

      @startdate = params[:startdate]
      @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?
  
      @insuranceexpenses = Invoice.where('kosongan = false AND invoices.is_insurance = true AND invoices.date between ? and ? AND invoices.id not in (select invoice_id from insuranceexpenses where deleted = false) AND invoices.id not in (select invoice_id from invoicereturns where deleted = false)', @startdate.to_date, @enddate.to_date).order(:date, :event_id)
  
      @commodity_id = params[:commodity_id]

      if @commodity_id.present?
        @insuranceexpenses = @insuranceexpenses.joins(:event).where('events.commodity_id = ?', @commodity_id)
      end


      respond_to :html

    else
      redirect_to root_path()
    end

  end

  def index
    role = cek_roles(@user_role)
    unless role
      redirect_to root_path
      return
    end

    @where = "insuranceexpenses"
    @startdate = params[:startdate].present? ? params[:startdate] : Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate].present? ? params[:enddate] : Date.today.strftime('%d-%m-%Y')

    date_range = @startdate.to_date..@enddate.to_date

    excluded_invoice_ids = (Insuranceexpense.where(deleted: false).select(:invoice_id).map(&:invoice_id) +
                             Invoicereturn.where(deleted: false).select(:invoice_id).map(&:invoice_id)).flatten.uniq

    base_insurance_scope = Invoice.joins(:event)
                             .where(is_insurance: true,
                                    date: date_range)
                             .where('invoices.id not in (?)',excluded_invoice_ids)
                             .where('events.tsi_total > money(0)')
                             .where('events.is_insurance = ?', true)

    @insuranceexpenses = base_insurance_scope.where(invoicetrain: false).order(:date, :event_id)
    @insuranceexpenses_loading = base_insurance_scope.where(invoicetrain: true).where('invoice_id is null').order(:date, :event_id)
    @insuranceexpenses_dooring = base_insurance_scope.where(invoicetrain: true).where('invoice_id is not null').order(:date, :event_id)
    @insuranceexpenses_losing = base_insurance_scope.where(invoicetrain: false, 'events.losing' => true).order(:date, :event_id) # Using hash syntax for string key

    @commodity_id = params[:commodity_id]
    if @commodity_id.present?
      @insuranceexpenses = @insuranceexpenses.joins(:event).where('events.commodity_id = ?', @commodity_id)
      @insuranceexpenses_loading = @insuranceexpenses_loading.joins(:event).where('events.commodity_id = ?', @commodity_id)
      @insuranceexpenses_dooring = @insuranceexpenses_dooring.joins(:event).where('events.commodity_id = ?', @commodity_id)
      @insuranceexpenses_losing = @insuranceexpenses_losing.joins(:event).where('events.commodity_id = ?', @commodity_id)
    end

    respond_to :html
  end

  def paid_old
    @where = "insuranceexpenses-paid"

    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @insurancevendor_id = params[:insurancevendor_id]
    @commodity_id = params[:commodity_id]

    # @insuranceexpenses = Invoice.where('invoiceinsurance = true AND routeinsurance_id is not null AND routeinsurance_id !=0  AND date between ? and ? AND invoices.id in (select invoice_id from insuranceexpenses where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)
    @insuranceexpenses = Insuranceexpense.where('insuranceexpenses.date between ? and ? and insuranceexpenses.deleted = false', @startdate.to_date, @enddate.to_date).order(:id)

    if @insurancevendor_id.present?
      @insuranceexpenses = @insuranceexpenses.joins(:invoice).where('insuranceexpenses.insurancevendor_id = ?', @insurancevendor_id)
    end

    if @commodity_id.present?
      @insuranceexpenses = @insuranceexpenses.joins(invoice: :event).where('events.commodity_id = ?', @commodity_id)
    end

    respond_to :html
  
  end

  def paid
    @where = "insuranceexpenses-paid"
    @startdate = params[:startdate].presence || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate].presence || Date.today.strftime('%d-%m-%Y')
    date_range = @startdate.to_date..@enddate.to_date

    base_paid_scope = Insuranceexpense.joins(invoice: :event)
                                     .where(insuranceexpenses: { date: date_range, deleted: false })
                                     .order('insuranceexpenses.id')

    @insuranceexpenses = base_paid_scope.where('invoices.invoicetrain = false')
    @insuranceexpenses_loading = base_paid_scope.where('invoices.invoicetrain = true AND invoices.invoice_id IS NULL')
    @insuranceexpenses_dooring = base_paid_scope.where('invoices.invoicetrain = true AND invoices.invoice_id IS NOT NULL')
    @insuranceexpenses_losing = base_paid_scope.where('invoices.invoicetrain = false AND events.losing = true')

    @insurancevendor_id = params[:insurancevendor_id]
    if @insurancevendor_id.present?
      @insuranceexpenses = @insuranceexpenses.where(insuranceexpenses: { insurancevendor_id: @insurancevendor_id })
      @insuranceexpenses_loading = @insuranceexpenses.where(insuranceexpenses: { insurancevendor_id: @insurancevendor_id })
      @insuranceexpenses_dooring = @insuranceexpenses.where(insuranceexpenses: { insurancevendor_id: @insurancevendor_id })
      @insuranceexpenses_losing = @insuranceexpenses.where(insuranceexpenses: { insurancevendor_id: @insurancevendor_id })
    end

    @commodity_id = params[:commodity_id]
    if @commodity_id.present?
      @insuranceexpenses = @insuranceexpenses.where('events.commodity_id = ?', @commodity_id)
      @insuranceexpenses_loading = @insuranceexpenses.where('events.commodity_id = ?', @commodity_id)
      @insuranceexpenses_dooring = @insuranceexpenses.where('events.commodity_id = ?', @commodity_id)
      @insuranceexpenses_losing = @insuranceexpenses.where('events.commodity_id = ?', @commodity_id)
    end

    respond_to :html
  end

  def new
    @where = "insuranceexpenses"
    
    @errors = Hash.new
    @invoice_id = params[:invoice_id]
    @invoice = Invoice.find(params[:invoice_id]) rescue nil
    @insuranceexpense = Insuranceexpense.new
    respond_to :html
  end

  def edit
    @insuranceexpense = Insuranceexpense.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:insuranceexpense]
    inputs[:tsi_total] = clean_currency(inputs[:price_per])
    # inputs[:gst_tax] = clean_currency(inputs[:gst_tax])
    # inputs[:gst_percentage] = clean_currency(inputs[:gst_tax]).to_i > 0 ? 11 : 0
    # inputs[:misc_total] = clean_currency(inputs[:misc_total])
    inputs[:total] = clean_currency(inputs[:total])
    # render json: inputs
    # return false
    @insuranceexpense = Insuranceexpense.new(inputs)
    @insuranceexpense.date = Date.today

    if @insuranceexpense.save
      redirect_to(insuranceexpenses_url(), :notice => 'Data Biaya Asuransi sukses ditambah.')
    else
      redirect_to(new_insuranceexpense_url(), :notice => 'Data Biaya Asuransi gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:insuranceexpense]
    @insuranceexpense = Insuranceexpense.find(params[:id])

    if @insuranceexpense.update_attributes(inputs)
      @insuranceexpense.save
      redirect_to(edit_insuranceexpense_url(@insuranceexpense), :notice => 'Data Biaya Asuransi sukses disimpan.')
    else
      redirect_to(edit_insuranceexpense_url(@insuranceexpense), :notice => 'Data Biaya Asuransi gagal diedit. Data Harus Unik.')
    end
  end

  def delete
    @insuranceexpense = Insuranceexpense.where('invoice_id = ? AND deleted = false', params[:invoice_id])[0]

    @insuranceexpense.deleted = true
    @insuranceexpense.deleteuser_id = current_user.id
    @insuranceexpense.save
    redirect_to(insuranceexpenses_url)
  end

  def destroy
    @insuranceexpense = Insuranceexpense.find(params[:id])
    @insuranceexpense.deleted = true
    @insuranceexpense.save
    redirect_to(insuranceexpenses_url)
  end  
  
  def enable
    @insuranceexpense = Insuranceexpense.find(params[:id])
    @insuranceexpense.update_attributes(:enabled => true)
    redirect_to(insuranceexpenses_url)
  end
  
  def disable
    @insuranceexpense = Insuranceexpense.find(params[:id])
    @insuranceexpense.update_attributes(:enabled => false)
    redirect_to(insuranceexpenses_url)
  end
end