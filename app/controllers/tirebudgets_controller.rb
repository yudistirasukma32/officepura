class TirebudgetsController < ApplicationController
	include ApplicationHelper
	layout "application"
  protect_from_forgery :except => [:updateitems]
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
  end

  def update
    inputs = params[:tirebudget]
    @tirebudget = Tirebudget.find(inputs[:id])
    if @tirebudget.update_attributes(inputs)
      @tirebudget.save
      @productgroup = Productgroup.find(@tirebudget.productgroup_id)
      redirect_to(edit_vehicle_url(@tirebudget.vehicle_id)+"/#3", :notice => 'Data target [' + @productgroup.name + '] sukses di simpan.')
    end
  end

  def updateitems
    @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
    @vehicle.tirebudgets.each do |tirebudget|
      tirebudget.budget = params["budget"][tirebudget.id.to_s]
      tirebudget.save
    end
    redirect_to(edit_vehicle_url(@vehicle)+"/#3", :notice => 'Data target ban sukses tersimpan.')
  end

end
