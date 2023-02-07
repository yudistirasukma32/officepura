class InsurancevendorsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "insurancevendors"
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role
      @insurancevendors = Insurancevendor.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @insurancevendor = Insurancevendor.new
    @insurancevendor.enabled = true
    respond_to :html
  end

  def edit
    @insurancevendor = Insurancevendor.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:insurancevendor]
    @insurancevendor = Insurancevendor.new(inputs)

    if @insurancevendor.save
      redirect_to(insurancevendors_url(), :notice => 'Data Vendor sukses ditambah.')
    else
      redirect_to(new_container_url(), :notice => 'Data Vendor gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:insurancevendor]
    @insurancevendor = Insurancevendor.find(params[:id])

    if @insurancevendor.update_attributes(inputs)
      @insurancevendor.save
      redirect_to(edit_container_url(@insurancevendor), :notice => 'Data Vendor sukses disimpan.')
    else
      redirect_to(edit_container_url(@insurancevendor), :notice => 'Data Vendor gagal diedit. Data Harus Unik.')
    end
  end

  def destroy
    @insurancevendor = Insurancevendor.find(params[:id])
    @insurancevendor.deleted = true
    @insurancevendor.save
    redirect_to(insurancevendors_url)
  end  
  
  def enable
    @insurancevendor = Insurancevendor.find(params[:id])
    @insurancevendor.update_attributes(:enabled => true)
    redirect_to(insurancevendors_url)
  end
  
  def disable
    @insurancevendor = Insurancevendor.find(params[:id])
    @insurancevendor.update_attributes(:enabled => false)
    redirect_to(insurancevendors_url)
  end
end