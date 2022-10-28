class ShipsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_ship
	before_filter :set_ship, only: [:edit, :update, :destroy]

  respond_to :html
	
	def set_section
    @section = "masters"
    @where = "ships"
  end

  def index
    @ships = Ship.all
    respond_with(@ships)
  end

  def new
    @ship = Ship.new
    respond_with(@ships)
  end

  def edit
  	respond_with(@ship)
  end

  def create
    @ship = Ship.new(params[:ship])
    @ship.save
		redirect_to(ships_path, :notice => 'Data Kapal sukses disimpan')
  end

  def update
    if @ship.update_attributes(params[:ship])
      @ship.save
      redirect_to(ships_path, :notice => 'Data Kapal sukses diupdate')
    else
      to_flash(@ship)
      render :action => "edit"
    end
  end

  def destroy
    @ship = Ship.find(params[:id])
    @ship.deleted = true
    @ship.save
		redirect_to(ships_path, :notice => 'Data Kapal sukses dihapus')
  end

  private
    def set_ship
      @ship = Ship.find(params[:id])
    end
end

