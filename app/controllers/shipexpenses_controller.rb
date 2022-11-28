class ShipexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "transactions"
    @where = "shipexpenses"
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

    @shipexpenses = Invoice.where('routeship_id is not null AND routeship_id !=0  AND date between ? and ? AND invoices.id not in (select invoice_id from shipexpenses where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)

    if @operator_id.present?
      @shipexpenses = @shipexpenses.where('invoices.operator_id = ?', @operator_id)
    end

  end

  def new
    @errors = Hash.new
    @invoice_id = params[:invoice_id]
    @invoice = Invoice.find(params[:invoice_id]) rescue nil
    @shipexpense = Shipexpense.new
    respond_to :html
  end

  def edit
    @shipexpense = Shipexpense.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:shipexpense]
    
    @shipexpense = Shipexpense.new(inputs)
    @shipexpense.date = Date.today

    if @shipexpense.save
      redirect_to(shipexpenses_url(), :notice => 'Data Biaya Operator Kapal sukses ditambah.')
    else
      redirect_to(new_shipexpense_url(), :notice => 'Data Biaya Operator Kapal gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:shipexpense]
    @shipexpense = Shipexpense.find(params[:id])

    if @shipexpense.update_attributes(inputs)
      @shipexpense.save
      redirect_to(edit_shipexpense_url(@shipexpense), :notice => 'Data Biaya Operator Kapal sukses disimpan.')
    else
      redirect_to(edit_shipexpense_url(@shipexpense), :notice => 'Data Biaya Operator Kapal gagal diedit. Data Harus Unik.')
    end
  end

  def delete
    @shipexpense = Shipexpense.where('invoice_id = ? AND deleted = false', params[:invoice_id])[0]

    @shipexpense.deleted = true
    @shipexpense.deleteuser_id = current_user.id
    @shipexpense.save
    redirect_to(shipexpenses_url)
  end

  def destroy
    @shipexpense = Shipexpense.find(params[:id])
    @shipexpense.deleted = true
    @shipexpense.save
    redirect_to(shipexpenses_url)
  end  
  
  def enable
    @shipexpense = Shipexpense.find(params[:id])
    @shipexpense.update_attributes(:enabled => true)
    redirect_to(shipexpenses_url)
  end
  
  def disable
    @shipexpense = Shipexpense.find(params[:id])
    @shipexpense.update_attributes(:enabled => false)
    redirect_to(shipexpenses_url)
  end
end