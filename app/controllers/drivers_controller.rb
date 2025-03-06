class DriversController < ApplicationController
  require "uri"
  require "net/http"
  require "openssl"
  require 'json'
	include ApplicationHelper
	layout "application"
  protect_from_forgery :except => [:create, :update]
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "drivers"
    @statuses = ["Tetap", "Warnen"]
    @attachments_category = ["KTP", "FOTO", "BPJS", "SIM", "NPWP", "Lainnya"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Operasional BKK, Vendor Supir, Admin Supir'
    @vendor = 'Vendor Supir'
  end

  def index
    role = cek_roles @user_role
    if role

      vendor_role = checkroleonly @vendor

      if vendor_role

        @vendor = Vendor.where('user_id = ?', current_user.id)
        
        if @vendor.present?
          @drivers = Driver.order('name')
          @drivers = @drivers.where("vendor_id = ?", @vendor[0].id)
        end

      else

        @origin = params[:origin]
        @is_resign = params[:is_resign]
        @vendor_id = params[:vendor_id]
  
        @drivers = Driver.order('name')
  
        if @origin.present? and @origin != ''
            @drivers = @drivers.where("origin = ?", @origin)
        end
  
        if @is_resign.present? and @is_resign != 'No'
            @drivers = @drivers.where("is_resign = true")
        end
  
        if @is_resign.present? and @is_resign == 'No'
          @drivers = @drivers.where("is_resign = false")
        end
  
      end

      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def new
    @process = 'new'

    @driver = Driver.new
    @driver.enabled = true
    @driver.weight_loss = @driver.weight_loss.to_i
    @driver.accident = @driver.accident.to_i
    @driver.sparepart = @driver.sparepart.to_i
    @driver.bon = @driver.bon.to_i
    @driver.saving = @driver.saving.to_i
    @vehicles = Vehicle.where("id not in (select vehicle_id from drivers where deleted = false) and deleted = false").order(:current_id)
  end

  def edit

    @process = 'edit'

    @driver = Driver.find(params[:id])
    @helper = @driver.helpers.first
    @helper = Helper.new if !@helper
    @vehicles = Vehicle.where("deleted = false and id not in (select vehicle_id from drivers where deleted = false)").order(:current_id)

    @driver.salary = @driver.salary.to_i
    @helper.salary = @helper.salary.to_i
    @driver.weight_loss = @driver.weight_loss.to_i
    @driver.accident = @driver.accident.to_i
    @driver.sparepart = @driver.sparepart.to_i
    @driver.bon = @driver.bon.to_i
    @driver.saving = @driver.saving.to_i
    @driver.driver_licence_expiry = @driver.driver_licence_expiry.strftime('%d-%m-%Y') if !@driver.driver_licence_expiry.blank?
    @driver.id_card_expiry = @driver.id_card_expiry.strftime('%d-%m-%Y') if !@driver.id_card_expiry.blank?
    @driver.start_working = @driver.start_working.strftime('%d-%m-%Y') if !@driver.start_working.blank?

    @helper.weight_loss = @helper.weight_loss.to_i
    @helper.accident = @helper.accident.to_i
    @helper.sparepart = @helper.sparepart.to_i
    @helper.bon = @helper.bon.to_i
    @helper.saving = @helper.saving.to_i
    @helper.driver_licence_expiry = @helper.driver_licence_expiry.strftime('%d-%m-%Y') if !@helper.driver_licence_expiry.blank?
    @helper.id_card_expiry = @helper.id_card_expiry.strftime('%d-%m-%Y') if !@helper.id_card_expiry.blank?

    # render json: @driver.bank_account
  end

  def create_bank_expense_group
    # Bankexpensegroup.
    Driver.active.each do |driver|
      bank_expense_group = Bankexpensegroup.create({
        name: "Bank Supir #{driver.name}",
        bankexpensegroup_id: 137
      })

      driver.bankexpensegroup_id = bank_expense_group.id
      driver.save
    end
  end

  def create
    inputs = params[:driver]
    @driver = Driver.new(inputs)

    @driver.is_resign = inputs[:is_resign] == "1" ? true : false
    @driver.blacklist = inputs[:blacklist] == "1" ? true : false

    if @driver.save
      inputs[:origin_id] = @driver.id
      url = URI("https://finance.quncinesia.id/people/api/postapi_people")
      # url = URI("http://localhost:3001/people/api/postapi_people")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url.request_uri)
      request["Content-Type"] = "application/json"
      request.body = JSON.dump(inputs)

      response = http.request(request)
      @response = response.read_body

      if @driver.blacklist
        redirect_to(edit_driver_url(@driver, blacklist: 1), :notice => 'Data Supir Daftar Hitam sukses ditambah.')
      
      else
      
        redirect_to(edit_driver_url(@driver), :notice => 'Data Supir sukses ditambah.')
      
      end

    else
      to_flash(@driver)
      render :action => "new"
    end
  end

  def update
    inputs = params[:driver]
    @driver = Driver.find(params[:id])

    @driver.is_resign = inputs[:is_resign] == "1" ? true : false

    if @driver.update_attributes(inputs)
      @driver.save
      inputs[:origin_id] = @driver.id
      url = URI("https://finance.quncinesia.id/people/api/postapi_people")
      # url = URI("http://localhost:3001/people/api/postapi_people")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Post.new(url.request_uri)
      request["Content-Type"] = "application/json"
      request.body = JSON.dump(inputs)

      response = http.request(request)
      @response = response.read_body
      
      redirect_to(edit_driver_url(@driver), :notice => 'Data Supir sukses disimpan.')
    else
      to_flash(@driver)
      render :action => "edit"
    end
  end

  def destroy
    @driver = Driver.find(params[:id])
    @driver.deleted = true
    @driver.save
    redirect_to(drivers_url)
  end  
  
  def enable
    @driver = Driver.find(params[:id])
    @driver.update_attributes(:enabled => true)
    redirect_to(drivers_url)
  end
  
  def disable
    @driver = Driver.find(params[:id])
    @driver.update_attributes(:enabled => false)
    redirect_to(drivers_url)
  end

  def blacklisted
    @driver = Driver.find(params[:id])
    @driver.update_attributes(:blacklist => true)
    redirect_to(edit_driver_url(@driver, blacklist: 1), :notice => 'Data Supir Daftar Hitam sukses ditambah.')
  end

  def whitelisted
    @driver = Driver.find(params[:id])
    @driver.update_attributes(:blacklist => false)
    redirect_to(edit_driver_url(@driver), :notice => 'Data Supir sukses diupdate.')
  end

  def blacklist
    role = cek_roles @user_role
    if role

      @origin = params[:origin]
      @is_resign = params[:is_resign]
      @vendor_id = params[:vendor_id]

      @drivers = Driver.blacklisted.order('name')

      if @origin.present? and @origin != ''
          @drivers = @drivers.where("origin = ?", @origin)
      end

      if @is_resign.present? and @is_resign != 'No'
          @drivers = @drivers.where("is_resign = true")
      end

      if @is_resign.present? and @is_resign == 'No'
        @drivers = @drivers.where("is_resign = false")
      end

      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def history
    @driver = Driver.find(params[:driver_id])
    # @invoices = Invoice.active.where('driver_id = ?', @driver.id).reorder('id DESC').limit(20)
    # @invoices = Invoice.active
    #                .where('driver_id = ? AND date >= ?', @driver.id, 2.weeks.ago)
    #                .reorder('id DESC')
    # @invoices = @invoices.where("id in (select invoice_id from receipts where deleted = false) AND id not in(select invoice_id from receiptreturns where deleted = false)")
    

    @invoices = Invoice.active
                   .where('driver_id = ? AND date >= ?', @driver.id, 2.weeks.ago)
                   .where("invoices.id IN (SELECT invoice_id FROM receipts WHERE deleted = false)")
                   .where("invoices.id NOT IN (SELECT invoice_id FROM receiptreturns WHERE deleted = false)")
                   .joins("JOIN receipts ON receipts.invoice_id = invoices.id AND receipts.deleted = false")
                   .order("receipts.created_at DESC")

    # render json: @invoices

    render :json => {:success => true, 
		:html => render_to_string(:partial => "drivers/history"), 
		:layout => false}.to_json;

  end
  
end
