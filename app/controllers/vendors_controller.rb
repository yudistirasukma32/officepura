class VendorsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "vendors"
    @where = "vendors"
    @categories = ["-", "Dry Container 20'", "Side Door Open 20'"]
    @groups = ["Container", "Truck", "Driver"]

  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role
      @vendors = Vendor.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @vendor = Vendor.new
    @vendor.enabled = true
    @users = User.where("deleted = false AND username LIKE 'vendor_%'")
    respond_to :html
  end

  def edit
    @vendor = Vendor.find(params[:id])
    @users = User.where("deleted = false AND username LIKE 'vendor_%'")
    respond_to :html
  end

  def create
    inputs = params[:vendor]
    @vendor = Vendor.new(inputs)

    if @vendor.save
      redirect_to(vendors_url(), :notice => 'Data Vendor sukses ditambah.')
    else
      redirect_to(new_vendor_url(), :notice => 'Data Vendor gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:vendor]
    @vendor = Vendor.find(params[:id])

    if @vendor.update_attributes(inputs)
      @vendor.save
      redirect_to(edit_vendor_url(@vendor), :notice => 'Data Vendor sukses disimpan.')
    else
      redirect_to(edit_vendor_url(@vendor), :notice => 'Data Vendor gagal diedit. Data Harus Unik.')
    end
  end

  def destroy
    @vendor = Vendor.find(params[:id])
    @vendor.deleted = true
    @vendor.save
    redirect_to(vendors_url)
  end  
  
  def enable
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes(:enabled => true)
    redirect_to(vendors_url)
  end
  
  def disable
    @vendor = Vendor.find(params[:id])
    @vendor.update_attributes(:enabled => false)
    redirect_to(vendors_url)
  end
end