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
    @user_role = 'Admin Operasional, Admin Keuangan'
  end

  def index
    @where = "insuranceexpenses"

    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @insuranceexpenses = Invoice.where('is_insurance = true AND date between ? and ? AND invoices.id not in (select invoice_id from insuranceexpenses where deleted = false) AND invoices.id not in (select invoice_id from invoicereturns where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)

    # if @operator_id.present?
    #   @insuranceexpenses = @insuranceexpenses.where('invoices.operator_id = ?', @operator_id)
    # end
    respond_to :html

  end

  def paid
    @where = "insuranceexpenses-paid"

    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @insurancevendor_id = params[:insurancevendor_id]
    @containertype = params[:containertype]

    # @insuranceexpenses = Invoice.where('invoiceinsurance = true AND routeinsurance_id is not null AND routeinsurance_id !=0  AND date between ? and ? AND invoices.id in (select invoice_id from insuranceexpenses where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)
    @insuranceexpenses = Insuranceexpense.where('insuranceexpenses.date between ? and ? and insuranceexpenses.deleted = false', @startdate.to_date, @enddate.to_date).order(:id)

    # if @insurancevendor_id.present?
    #   @insuranceexpenses = @insuranceexpenses.joins(:invoice).where('invoices.operator_id = ?', @operator_id)
    # end
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