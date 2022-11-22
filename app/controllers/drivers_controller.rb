class DriversController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "drivers"
    @statuses = ["Tetap", "Warnen"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Operasional BKK'
  end

  def index
    role = cek_roles @user_role
    if role
      @drivers = Driver.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
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
  end

  def create
    inputs = params[:driver]
    @driver = Driver.new(inputs)

    if @driver.save
      redirect_to(edit_driver_url(@driver), :notice => 'Data Supir sukses di tambah.')
    else
      to_flash(@driver)
      render :action => "new"
    end
  end

  def update
    inputs = params[:driver]
    @driver = Driver.find(params[:id])

    if @driver.update_attributes(inputs)
      @driver.save
      redirect_to(edit_driver_url(@driver), :notice => 'Data Supir sukses di simpan.')
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

  def create_bank_expense_group
    # Bankexpensegroup.
    Driver.active.where("bankexpensegroup_id is null").each do |driver|
      bank_expense_group = Bankexpensegroup.create({
        name: "Bank Supir #{driver.name}",
        bankexpensegroup_id: 137
      })

      driver.bankexpensegroup_id = bank_expense_group.id
      driver.save
    end
  end

  def clone
    require "uri"
		require "net/http"
		require "openssl"
		require 'json'

    # url = URI("https://office.puratrans.com/api_customers/get_all_customers")
    url = URI("https://internal.puratrans.com/api/driversapi/list_sangu")

		http = Net::HTTP.new(url.host, url.port)
		# http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
		@drivers = ActiveSupport::JSON.decode(response.read_body)
    # render json: destination_drivers[0]
  end

  def save_clone
    require "uri"
		require "net/http"
		require "openssl"
		require 'json'

    # url = URI("https://office.puratrans.com/api_customers/get_all_customers")
    url = URI("https://internal.puratrans.com/api/driversapi/list_sangu")

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
    driver_id = []
		ActiveSupport::JSON.decode(response.read_body).each do |driver|
      current_driver = Driver.where("name like '#{driver["name"]}%'").first
      if current_driver.present?
        driver_id.push(current_driver.id)
        current_driver.accident = driver["accident"].to_i
        current_driver.weight_loss = driver["weight_loss"].to_i
        current_driver.sparepart = driver["sparepart"].to_i
        current_driver.bon = driver["bon"].to_i
        current_driver.saving = driver["saving"].to_i
        current_driver.save

      end
    end
    
    render json: Driver.active.where(id: driver_id).select("id, accident, weight_loss, sparepart, bon, saving, name")

  end
end
