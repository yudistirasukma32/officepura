class RouteshipsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "routeships"
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan, Admin Jurusan'
  end

  def index
    role = cek_roles @user_role
    if role
      @routes = Routeship.active.order(:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @routeship = Routeship.new
    @routeship.enabled = true
    respond_to :html
  end

  def edit
    @routeship = Routeship.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:routeship]
    @routeship = Routeship.new(inputs)

    if @routeship.save
      redirect_to(routeships_url(), :notice => 'Data Jurusan Pelabuhan sukses ditambah.')
    else
      redirect_to(new_routeship_url(), :notice => 'Data Jurusan Pelabuhan gagal ditambah. Data Harus Lengkap.')
    end
  end

  def update
    inputs = params[:routeship]
    @routeship = Routeship.find(params[:id])

    if @routeship.update_attributes(inputs)
      @routeship.save
      redirect_to(edit_routeship_url(@routeship), :notice => 'Data Jurusan Pelabuhan sukses disimpan.')
    else
      redirect_to(edit_routeship_url(@routeship), :notice => 'Data Jurusan Pelabuhan gagal diedit. Data Harus Lengkap.')
    end
  end

  def destroy
    @routeship = Routeship.find(params[:id])
    @routeship.deleted = true
    @routeship.save
    redirect_to(routeships_url)
  end  
  
  def enable
    @routeship = Routeship.find(params[:id])
    @routeship.update_attributes(:enabled => true)
    redirect_to(routeships_url)
  end
  
  def disable
    @routeship = Routeship.find(params[:id])
    @routeship.update_attributes(:enabled => false)
    redirect_to(routeships_url)
  end
end