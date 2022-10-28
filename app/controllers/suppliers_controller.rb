class SuppliersController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "suppliers"
  end

  def set_role
    @user_role = 'Admin Gudang'
  end

  def index
    role = cek_roles @user_role
    if role
      @suppliers = Supplier.all(:order => :name)
      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def new
    @supplier = Supplier.new
    @supplier.enabled = true
    respond_to :html
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def create
    inputs = params[:supplier]
    @supplier = Supplier.new(inputs)

    if @supplier.save
      redirect_to(edit_supplier_url(@supplier), :notice => 'Data Supplier sukses di tambah.')
    else
      to_flash(@supplier)
      render :action => "new"
    end
  end

  def update
    inputs = params[:supplier]
    @supplier = Supplier.find(params[:id])

    if @supplier.update_attributes(inputs)
      @supplier.save
      redirect_to(edit_supplier_url(@supplier), :notice => 'Data Supplier sukses di simpan.')
    else
      to_flash(@supplier)
      render :action => "edit"
    end
  end

  def destroy
    @supplier = Supplier.find(params[:id])
    @supplier.deleted = true
    @suppler.save
    redirect_to(suppliers_url)
  end  
  
  def enable
    @supplier = Supplier.find(params[:id])
    @supplier.update_attributes(:enabled => true)
    redirect_to(suppliers_url)
  end
  
  def disable
    @supplier = Supplier.find(params[:id])
    @supplier.update_attributes(:enabled => false)
    redirect_to(suppliers_url)
  end
end
