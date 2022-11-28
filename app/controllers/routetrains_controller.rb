class RoutetrainsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "routetrains"
    
    @contype = ["ISOTANK 20FT", "ISOTANK EMPTY 20FT", "DRY CONTAINER EMPTY 20FT", "DRY CONTAINER 20FT", "DRY CONTAINER EMPTY 40FT", "DRY CONTAINER 40FT"]
    
    @consize = ["20FT", "40FT"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan, Admin Jurusan'
  end

  def index
    role = cek_roles @user_role
    if role
      @routes = Routetrain.active.order(:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @routetrain = Routetrain.new
    @routetrain.enabled = true
    respond_to :html
  end

  def edit
    @routetrain = Routetrain.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:routetrain]
    if inputs[:gst_tax].present?
      inputs[:gst_tax] = (inputs[:price_per].to_i * 11 / 100).to_i
    else
      inputs[:gst_tax] = 0
    end
    @routetrain = Routetrain.new(inputs)
    if @routetrain.save
      redirect_to(routetrains_url(), :notice => 'Data Jurusan Kereta sukses ditambah.')
    else
      redirect_to(new_routetrain_url(), :notice => 'Data Jurusan Kereta gagal ditambah. Data Harus Lengkap.')
    end
  end

  def update
    inputs = params[:routetrain]
    @routetrain = Routetrain.find(params[:id])
    if inputs[:gst_tax].present?
      inputs[:gst_tax] = (inputs[:price_per].to_i * 11 / 100).to_i
    else
      inputs[:gst_tax] = 0
    end
    if @routetrain.update_attributes(inputs)
      @routetrain.save
      redirect_to(edit_routetrain_url(@routetrain), :notice => 'Data Jurusan Kereta sukses disimpan.')
    else
      redirect_to(edit_routetrain_url(@routetrain), :notice => 'Data Jurusan Kereta gagal diedit. Data Harus Lengkap.')
    end
  end

  def destroy
    @routetrain = Routetrain.find(params[:id])
    @routetrain.deleted = true
    @routetrain.save
    redirect_to(routetrains_url)
  end  
  
  def enable
    @routetrain = Routetrain.find(params[:id])
    @routetrain.update_attributes(:enabled => true)
    redirect_to(routetrains_url)
  end
  
  def disable
    @routetrain = Routetrain.find(params[:id])
    @routetrain.update_attributes(:enabled => false)
    redirect_to(routetrains_url)
  end
end