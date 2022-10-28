class VehiclelogsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "logs"
    @where = "vehiclelogs"
  end

  def index
    @vehicles = Vehicle.where(:deleted => false).order("enabled DESC, current_id")
    respond_to :html
  end

  def vehicledates
    @where = "vehicledates"
    @vehicles = Vehicle.where(:deleted => false).order("current_id")
    respond_to :html
  end

  def new
    @vehicle = Vehicle.find(params[:vehicle_id])
    @vehiclelog = Vehiclelog.new
    @vehiclelog.vehicle_id = @vehicle.id
    @vehiclelog.ready = !@vehicle.enabled

    if @vehicle.enabled
      @status = "Tidak Ready"
    else
      @status = "Ready"
    end
  end

  def create
    inputs = params[:vehiclelog]
    @vehiclelog = Vehiclelog.new(inputs)
    @vehicle = Vehicle.find(inputs[:vehicle_id])

    if @vehiclelog.save
      @vehicle.enabled = @vehiclelog.ready
      @vehicle.save
      redirect_to(vehiclelogs_url, :notice => 'Data Status ' + @vehicle.current_id + ' sukses di simpan.')
    else
      to_flash(@vehiclelog)
      render :action => "new"
    end
  end

end
