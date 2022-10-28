class AllowancesController < ApplicationController
	include ApplicationHelper
	layout "application"
  protect_from_forgery :except => [:updateitems]
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
  end

  def update
    inputs = params[:allowance]
    @allowance = Allowance.find(inputs[:id])
    if @allowance.update_attributes(inputs)
      @allowance.save
      @vehiclegroup = Vehiclegroup.find(@allowance.vehiclegroup_id)
      redirect_to(edit_route_url(@allowance.route_id)+"/#2", :notice => 'Data Ongkos [' + @vehiclegroup.name + '] sukses di simpan.')
    end
  end

  def updateitems
    @route = Route.find(params[:route_id]) rescue nil
    @route.allowances.each do |allowance|
      allowance.driver_trip = params["driver_trip"][allowance.id.to_s]
      allowance.helper_trip = params["helper_trip"][allowance.id.to_s]
      allowance.gas_trip = params["gas_trip"][allowance.id.to_s]
      allowance.misc_allowance = params["misc_allowance"][allowance.id.to_s]
      allowance.train_trip = params["train_trip"][allowance.id.to_s]
      allowance.save
    end
    redirect_to(edit_route_url(@route)+"/#2", :notice => 'Data Sangu + Solar sukses di simpan.')
  end

end
