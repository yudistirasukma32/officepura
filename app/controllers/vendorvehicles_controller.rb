class VendorvehiclesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "vendorvehicles"
    @where = "vendorvehicles"
    @categories = ["BELI", "SEWA", "FREEUSE"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role
      @vendorvehicles = Vendorvehicle.all(:order =>:current_id)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @vendorvehicle = Vendorvehicle.new
    @vendorvehicle.enabled = true
    respond_to :html
  end

  def edit
    @vendorvehicle = Vendorvehicle.find(params[:id])

    respond_to :html
  end

  def create
    inputs = params[:vendorvehicle]
    @vendorvehicle = Vendorvehicle.new(inputs)

    if @vendorvehicle.save
      redirect_to(vendorvehicles_url(), :notice => 'Data Vendor Kendaraan sukses ditambah.')
    else
      redirect_to(new_vendorvehicle_url(), :notice => 'Data Vendor Kendaraan gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:vendorvehicle]
    @vendorvehicle = Vendorvehicle.find(params[:id])

    if @vendorvehicle.update_attributes(inputs)
      @vendorvehicle.save
      redirect_to(edit_vendorvehicle_url(@vendorvehicle), :notice => 'Data Vendor Kendaraan sukses disimpan.')
    else
      redirect_to(edit_vendorvehicle_url(@vendorvehicle), :notice => 'Data Vendor Kendaraan gagal diedit. Data Harus Unik.')
    end
  end

  def destroy
    @vendorvehicle = Vendorvehicle.find(params[:id])
    @vendorvehicle.deleted = true
    @vendorvehicle.save
    redirect_to(vendorvehicles_url)
  end  
  
  def enable
    @vendorvehicle = Vendorvehicle.find(params[:id])
    @vendorvehicle.update_attributes(:enabled => true)
    redirect_to(vendorvehicles_url)
  end
  
  def disable
    @vendorvehicle = Vendorvehicle.find(params[:id])
    @vendorvehicle.update_attributes(:enabled => false)
    redirect_to(vendorvehicles_url)
  end
end