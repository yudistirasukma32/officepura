class MechanicsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  respond_to :html
	
	def set_section
    @section = "masters"
    @where = "mechanics"
  end

  def index
    @mechanics = Mechanic.all
    respond_with(@mechanics)
  end

  def new
    @mechanic = Mechanic.new
    respond_with(@mechanics)
  end

  def edit
    @mechanic = Mechanic.find(params[:id])
  	respond_with(@mechanic)
  end

  def create
    @mechanic = Mechanic.new(params[:mechanic])
    @mechanic.save
		redirect_to(mechanics_path, :notice => 'Data Mekanik sukses disimpan')
  end

  def update
    inputs = params[:mechanic]
    @mechanic = Mechanic.find(params[:id])
    if @mechanic.update_attributes(inputs)
      @mechanic.save
      redirect_to(mechanics_path, :notice => 'Data Mekanik sukses diupdate')
    else
      to_flash(@mechanic)
      render :action => "edit"
    end
  end

  def destroy
    @mechanic = Mechanic.find(params[:id])
    @mechanic.deleted = true
    @mechanic.save
		redirect_to(mechanics_path, :notice => 'Data Mekanik sukses dihapus')
  end

  private
    def set_mechanic
      @mechanic = Mechanic.find(params[:id])
    end
end

