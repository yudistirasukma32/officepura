class TrainexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "transactions"
    @where = "trainexpenses"
    
    @contype = ["ISOTANK 20FT", "ISOTANK EMPTY 20FT", "DRY CONTAINER EMPTY 20FT", "DRY CONTAINER 20FT", "DRY CONTAINER EMPTY 40FT", "DRY CONTAINER 40FT"]
    
    @consize = ["20FT", "40FT"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin Keuangan'
  end

  def index
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @operator_id = params[:operator_id]
        @containertype = params[:containertype]
    
        @trainexpenses = Invoice.where('invoicetrain = true AND routetrain_id is not null AND routetrain_id !=0  AND date between ? and ? AND invoices.id not in (select invoice_id from trainexpenses where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)
    
        if @operator_id.present?
          @trainexpenses = @trainexpenses.where('invoices.operator_id = ?', @operator_id)
        end
    
        if @containertype.present?
          @trainexpenses = @trainexpenses.joins(:routetrain).where('routetrains.container_type = ?', @containertype)
        end

  end

  def new
    @errors = Hash.new
    @invoice_id = params[:invoice_id]
    @invoice = Invoice.find(params[:invoice_id]) rescue nil
    @trainexpense = Trainexpense.new
    respond_to :html
  end

  def edit
    @trainexpense = Trainexpense.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:trainexpense]
    inputs[:price_per] = clean_currency(inputs[:price_per])
    inputs[:gst_tax] = clean_currency(inputs[:gst_tax])
    inputs[:gst_percentage] = clean_currency(inputs[:gst_tax]).to_i > 0 ? 11 : 0
    inputs[:total] = clean_currency(inputs[:total])
    # render json: inputs
    # return false
    @trainexpense = Trainexpense.new(inputs)
    @trainexpense.date = Date.today

    if @trainexpense.save
      redirect_to(trainexpenses_url(), :notice => 'Data Biaya Kereta sukses ditambah.')
    else
      redirect_to(new_trainexpense_url(), :notice => 'Data Biaya Kereta gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:trainexpense]
    @trainexpense = Trainexpense.find(params[:id])

    if @trainexpense.update_attributes(inputs)
      @trainexpense.save
      redirect_to(edit_trainexpense_url(@trainexpense), :notice => 'Data Biaya Kereta sukses disimpan.')
    else
      redirect_to(edit_trainexpense_url(@trainexpense), :notice => 'Data Biaya Kereta gagal diedit. Data Harus Unik.')
    end
  end

  def delete
    @trainexpense = Trainexpense.where('invoice_id = ? AND deleted = false', params[:invoice_id])[0]

    @trainexpense.deleted = true
    @trainexpense.deleteuser_id = current_user.id
    @trainexpense.save
    redirect_to(trainexpenses_url)
  end

  def destroy
    @trainexpense = Trainexpense.find(params[:id])
    @trainexpense.deleted = true
    @trainexpense.save
    redirect_to(trainexpenses_url)
  end  
  
  def enable
    @trainexpense = Trainexpense.find(params[:id])
    @trainexpense.update_attributes(:enabled => true)
    redirect_to(trainexpenses_url)
  end
  
  def disable
    @trainexpense = Trainexpense.find(params[:id])
    @trainexpense.update_attributes(:enabled => false)
    redirect_to(trainexpenses_url)
  end
end