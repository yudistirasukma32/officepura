class VehiclegroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
    @where = "vehiclegroups"
  end

  def index
    @vehiclegroups = Vehiclegroup.all(:order => :name)
    respond_to :html
  end

  def new
    @vehiclegroup = Vehiclegroup.new
    @vehiclegroup.enabled = true
    respond_to :html
  end

  def edit
    @vehiclegroup = Vehiclegroup.find(params[:id])
  end

  def create
    inputs = params[:vehiclegroup]
    @vehiclegroup = Vehiclegroup.new(inputs)

    if @vehiclegroup.save
      redirect_to(edit_vehiclegroup_url(@vehiclegroup), :notice => 'Grup Kendaraan sukses di tambah.')
    else
      to_flash(@vehiclegroup)
      render :action => "new"
    end
  end

  def update
    inputs = params[:vehiclegroup]
    @vehiclegroup = Vehiclegroup.find(params[:id])

    if @vehiclegroup.update_attributes(inputs)
      @vehiclegroup.save
      redirect_to(edit_vehiclegroup_url(@vehiclegroup), :notice => 'Grup Kendaraan sukses di simpan.')
    else
      to_flash(@vehiclegroup)
      render :action => "edit"
    end
  end

  def destroy
    @vehiclegroup = Vehiclegroup.find(params[:id])
    @vehiclegroup.deleted = true
    @vehiclegroup.save
    redirect_to(vehiclegroups_url)
  end  
  
  def enable
    @vehiclegroup = Vehiclegroup.find(params[:id])
    @vehiclegroup.update_attributes(:enabled => true)
    redirect_to(vehiclegroups_url)
  end
  
  def disable
    @vehiclegroup = Vehiclegroup.find(params[:id])
    @vehiclegroup.update_attributes(:enabled => false)
    redirect_to(vehiclegroups_url)
  end
end
