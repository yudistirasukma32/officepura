class MechaniclogsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  respond_to :html
	
	def set_section
    @section = "mechaniclogs"
    @loggroups = ['ENGINE', 'ELECTRICITY', 'BAN', 'BODY', 'LAIN-LAIN']
    @grades = ['SANGAT BAIK', 'BAIK', 'CUKUP', 'KURANG', 'SANGAT KURANG']
    @requestlocations = ['garasi','storing']
    @requesttypes = ['repair','maintenance']
    @requestlevels = ['low','normal','high']
  end

  def index
    @where = "mechaniclogs"
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @invoices = Invoice.active.where("date between ? and ? AND id not in (select invoice_id from mechaniclogs where deleted = false and request_type = 'repair')", @startdate.to_date, @enddate.to_date).order(:id)

    if params[:invoice_id].present? && !params[:invoice_id].empty?
      @invoices = Invoice.active.where('id = ?', params[:invoice_id])
    end

    if params[:vehicle_id].present? && !params[:vehicle_id].empty?
      @invoices = @invoices.where('vehicle_id = ?', params[:vehicle_id])
    end

  end

  def proceed
    @where = "mechaniclogs-proceed"
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?
    @mechaniclogs = Mechaniclog.where("request_type = 'repair' AND date between ? and ?", @startdate.to_date, @enddate.to_date).order(:id)

    @mechanic_id = params[:mechanic_id]

    if @mechanic_id.present?
      @mechaniclogs = @mechaniclogs.where('mechanic_id = ?', @mechanic_id)
    end

    if params[:vehicle_id].present? && !params[:vehicle_id].empty?
      @mechaniclogs = @mechaniclogs.where('vehicle_id = ?', params[:vehicle_id])
    end

    # respond_with(@mechaniclogs)
  end

  def maintenance
    @where = "mechaniclogs-maintenance"
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?
    @mechaniclogs = Mechaniclog.where("request_type = 'maintenance' AND date between ? and ?", @startdate.to_date, @enddate.to_date).order(:id)

    @mechanic_id = params[:mechanic_id]

    if @mechanic_id.present?
      @mechaniclogs = @mechaniclogs.where('mechanic_id = ?', @mechanic_id)
    end

    if params[:vehicle_id].present? && !params[:vehicle_id].empty?
      @mechaniclogs = @mechaniclogs.where('vehicle_id = ?', params[:vehicle_id])
    end

    # respond_with(@mechaniclogs)
  end

  def new
    @process = "new"
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
    @process = "edit"
    @mechaniclog = Mechaniclog.find(params[:id])

    if @mechaniclog.request_type == 'repair'
      @where = "mechaniclogs-proceed"
    else
      @where = "mechaniclogs-maintenance"
    end
    
    invoice_id = @mechaniclog.invoice_id
    @invoice = Invoice.find(invoice_id) rescue nil
  	respond_to :html
  end

  def create
    @mechaniclog = Mechaniclog.new(params[:mechaniclog])

    if @mechaniclog.request_type == 'repair'
      @mechaniclog.office_id = @mechaniclog.invoice.office_id
    end

    @mechaniclog.save

    if @mechaniclog.save

      require "uri"
      require "json"
      require "net/http"

      url = URI("https://cfqnoscorhtigmmgeqvn.supabase.co/rest/v1/requests")

      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true

      # http = Net::HTTP.new(url.host, url.port)
      # http.use_ssl = true
      # request = Net::HTTP::Post.new(url)

      https.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(url.request_uri)

      request["apikey"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNmcW5vc2Nvcmh0aWdtbWdlcXZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE4MTMyNTcsImV4cCI6MjAzNzM4OTI1N30.83mp7AAZGLoGC6Tx3Zo0YJy1ordtGrn6vvjs1gtAtBU"
      request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNmcW5vc2Nvcmh0aWdtbWdlcXZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjE4MTMyNTcsImV4cCI6MjAzNzM4OTI1N30.83mp7AAZGLoGC6Tx3Zo0YJy1ordtGrn6vvjs1gtAtBU"
      request["Content-Type"] = "application/json"
      request["Prefer"] = "return=minimal"
      request.body = JSON.dump({
        "request_date": @mechaniclog.date,
        "description": @mechaniclog.description,
        "origin": "pura",
        "vehicle_number": @mechaniclog.vehicle.current_id,
        "vehicle_origin": "pura",
        "vehicle_origin_id": @mechaniclog.vehicle_id,
        "request_origin_id": @mechaniclog.id,
        "request_type": @mechaniclog.request_type,
        "request_level": @mechaniclog.request_level,
        "request_location": @mechaniclog.request_location,
        "driver_name": @mechaniclog.driver.name,
        "driver_origin_id": @mechaniclog.driver_id,
        "office_id": @mechaniclog.office_id,
        "office_abbr": @mechaniclog.office.abbr,
        "invoice_origin_id": @mechaniclog.invoice_id,
        "profile_id": "b05c3a97-839e-4a8f-a93f-7ca76209b8f6",
        "mechanic_name": @mechaniclog.mechanic.name,
      })

      response = https.request(request)
      puts response.read_body

      if @mechaniclog.request_type == 'repair'
        redirect_to('/mechaniclogs-proceed', :notice => 'Data Request Perbaikan berhasil disimpan')
      else
        redirect_to('/mechaniclogs-maintenance', :notice => 'Data Request Maintenance berhasil disimpan')
      end

    else

      to_flash(@mechaniclog)
      render :action => "index"
      
    end

  end

  def update
    inputs = params[:mechaniclog]
    @mechaniclog = Mechaniclog.find(params[:id])
    if @mechaniclog.update(inputs)
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


  # private
  #   def set_mechaniclog
  #     @mechaniclog = Mechaniclog.find(params[:id])
  #   end
 
  #   def params
  #     {:mechaniclog => params.fetch(:mechaniclog, {}).permit(
  #       :enabled, :deleted, :date, :invoice_id, :vehicle_id, :driver_id, :mechanic_id,
  #       :group, :description, :comment, :grade, :user_id, :deleteuser_id,
  #       :datetime_start, :datetime_end, 
  #       :office_id, :request_type, :request_level, :request_location, :finished
  #     )}
  #   end
end

