class PortsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_port
	before_filter :set_port, only: [:edit, :update, :destroy]

  respond_to :html
	
	def set_section
    @section = "masters"
    @where = "ports"
  end

  def index
    @ports = Port.all
    respond_with(@ports)
  end

  def new
    @port = Port.new
    respond_with(@ports)
  end

  def edit
  	respond_with(@port)
  end

  def create
    @port = Port.new(params[:port])
    @port.save
		redirect_to(ports_path, :notice => 'Data Pelabuhan sukses disimpan')
  end

  def update
    if @port.update_attributes(params[:port])
      @port.save
      redirect_to(ports_path, :notice => 'Data Pelabuhan sukses diupdate')
    else
      to_flash(@port)
      render :action => "edit"
    end
  end

  def destroy
    @port = Port.find(params[:id])
    @port.deleted = true
    @port.save
		redirect_to(ports_path, :notice => 'Data Pelabuhan sukses dihapus')
  end

  private
    def set_port
      @port = Port.find(params[:id])
    end
end

