class MechaniclogsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  respond_to :html
	
	def set_section
    @section = "mechaniclogs"
    @loggroups = ['ENGINE', 'ELECTRICITY', 'BAN', 'BODY', 'LAIN-LAIN']
    @grades = ['SANGAT BAIK', 'BAIK', 'CUKUP', 'KURANG', 'SANGAT KURANG']
  end

  def index
    @where = "mechaniclogs"
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @invoices = Invoice.where('date between ? and ? AND id not in (select invoice_id from mechaniclogs where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)

  end

  def done
    @where = "mechaniclogs-done"
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?
    @mechaniclogs = Mechaniclog.where('date between ? and ?', @startdate.to_date, @enddate.to_date).order(:id)

    @mechanic_id = params[:mechanic_id]

    if @mechanic_id.present?
      @mechaniclogs = @mechaniclogs.where('mechanic_id = ?', @mechanic_id)
    end

    # respond_with(@mechaniclogs)
  end

  def new
    @process == "new"
    @where = "mechaniclogs"
    
    # respond_with(@mechaniclogs)
    @errors = Hash.new
    @invoice_id = params[:invoice_id]
    @invoice = Invoice.find(params[:invoice_id]) rescue nil
    @mechaniclog = Mechaniclog.new
    @mechaniclog.date = Date.today.strftime('%d-%m-%Y')
    respond_to :html
  end

  def edit
    @process == "edit"
    @where = "mechaniclogs-done"
    @mechaniclog = Mechaniclog.find(params[:id])
    invoice_id = @mechaniclog.invoice_id
    @invoice = Invoice.find(invoice_id) rescue nil
  	respond_to :html
  end

  def create
    @mechaniclog = Mechaniclog.new(params[:mechaniclog])
    @mechaniclog.save
		redirect_to(mechaniclogs_path, :notice => 'Data Mekanik Log sukses disimpan')
  end

  def update
    inputs = params[:mechaniclog]
    @mechaniclog = Mechaniclog.find(params[:id])
    if @mechaniclog.update_attributes(inputs)
      @mechaniclog.save
      redirect_to(mechaniclogs_path, :notice => 'Data Mekanik Log sukses diupdate')
    else
      to_flash(@mechaniclog)
      render :action => "edit"
    end
  end

  def destroy
    @mechaniclog = Mechaniclog.find(params[:id])
    @mechaniclog.deleted = true
    @mechaniclog.save
		redirect_to(mechaniclogs_path, :notice => 'Data Mekanik Log sukses dihapus')
  end


  private
    def set_mechaniclog
      @mechaniclog = Mechaniclog.find(params[:id])
    end
end

