class VehiclesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "vehicles"
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role

      @enabled = params[:enabled]

      @vehicles = Vehicle.order("generic, current_id")

      if @enabled == 'active'

        @vehicles = Vehicle.where("enabled = true")

      elsif @enabled == 'inactive'

        @vehicles = Vehicle.where("enabled = false")

      else

        @vehicles = Vehicle.order("generic, current_id")

      end

      

      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def index_asset
    @where = "vehicles-asset"
    @vehicles = Vehicle.all(:order => :current_id)
    respond_to :html
  end

  def new
    @vehicle = Vehicle.new
    @vehicle.enabled = true
    respond_to :html
  end

  def edit
    @vehicle = Vehicle.find(params[:id])
    @vehiclelogs = @vehicle.vehiclelogs.active

    @vehicle.id_expiry = @vehicle.id_expiry.strftime('%d-%m-%Y') if !@vehicle.id_expiry.blank?
    @vehicle.next_checkup_date = @vehicle.next_checkup_date.strftime('%d-%m-%Y') if !@vehicle.next_checkup_date.blank?
    @vehicle.next_checkup_date_second = @vehicle.next_checkup_date_second.strftime('%d-%m-%Y') if !@vehicle.next_checkup_date_second.blank?
    @vehicle.next_tera_date = @vehicle.next_tera_date.strftime('%d-%m-%Y') if !@vehicle.next_tera_date.blank?
    @vehicle.next_registration_date = @vehicle.next_registration_date.strftime('%d-%m-%Y') if !@vehicle.next_registration_date.blank?
    @vehicle.next_tax_date = @vehicle.next_tax_date.strftime('%d-%m-%Y') if !@vehicle.next_tax_date.blank?
    @vehicle.siup = @vehicle.siup.strftime('%d-%m-%Y') if !@vehicle.siup.blank?
    
    @productgroups = Productgroup.active.where(:tire_flag => true).order(:name) rescue nil
    @productgroups.each do |g|
      if g.tirebudgets.where(:vehicle_id => @vehicle.id).first.nil?
        tirebudget = Tirebudget.new
        tirebudget.vehicle_id = @vehicle.id
        tirebudget.productgroup_id = g.id
        tirebudget.save
      end
    end

    respond_to :html
  end

  def edit_asset
    @where = "vehicles-asset"
    @vehicle = Vehicle.find(params[:id])
    @vehicle_id = @vehicle.id
    @vehicle.amount = @vehicle.amount.to_i
    respond_to :html
  end

  def create
    inputs = params[:vehicle]
    @vehicle = Vehicle.new(inputs)

    if @vehicle.save
      redirect_to(edit_vehicle_url(@vehicle), :notice => 'Data Kendaraan sukses di tambah.')
    else
      to_flash(@vehicle)
      render :action => "new"
    end
  end

  def update
    inputs = params[:vehicle]
    @vehicle = Vehicle.find(params[:id])

    old_data = @vehicle.current_id + ' // ' + @vehicle.vehiclegroup_id.to_s + ' // ' + @vehicle.platform_type + ' // ' + @vehicle.office_id.to_s + ' // ' + DateTime.now.to_s

    if @vehicle.update_attributes(inputs)

      @vehicle.user_id = current_user.id
      @vehicle.updated_by = current_user.username
      @vehicle.previous_data = old_data

      @vehicle.save
      redirect_to(edit_vehicle_url(@vehicle), :notice => 'Data Kendaraan sukses disimpan.')
    else
      to_flash(@vehicle)
      render :action => "edit"
    end
  end

  def update_asset
    inputs = params[:vehicle]
    @vehicle = Vehicle.find(inputs["vehicle_id"])
    
    @vehicle.date_purchase = inputs["date_purchase"]
    @vehicle.amount = inputs["amount"].to_i

    if @vehicle.save
      redirect_to("/vehicles/" + @vehicle.id.to_s + "/edit_asset", :notice => 'Data Aktiva Kendaraan sukses di simpan.')
    else
      to_flash(@vehicle)
      redirect_to("/vehicles/" + @vehicle.id.to_s + "/edit_asset")
    end
  end

  def destroy
    @vehicle = Vehicle.find(params[:id])
    @vehicle.deleted = true
    @vehicle.save
    redirect_to(vehicles_url)
  end  
  
  def enable
    @vehicle = Vehicle.find(params[:id])
    @vehicle.update_attributes(:enabled => true)
    redirect_to(vehicles_url)
  end
  
  def disable
    @vehicle = Vehicle.find(params[:id])
    @vehicle.update_attributes(:enabled => false)
    redirect_to(vehicles_url)
  end
end
