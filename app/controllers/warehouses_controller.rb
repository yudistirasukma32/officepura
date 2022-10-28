class WarehousesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
    @where = "warehouses"
  end

  def index
    @warehouses = Warehouse.all(:order =>:name)
    respond_to :html
  end

  def new
    @warehouse = Warehouse.new
    @warehouse.enabled = true
    respond_to :html
  end

  def edit
    @warehouse = Warehouse.find(params[:id])
  end

  def create
    inputs = params[:warehouse]
    @warehouse = Warehouse.new(inputs)

    if @warehouse.save
      redirect_to(edit_warehouse_url(@warehouse), :notice => 'Data Gudang sukses di tambah.')
    else
      to_flash(@warehouse)
      render :action => "new"
    end
  end

  def update
    inputs = params[:warehouse]
    @warehouse = Warehouse.find(params[:id])

    if @warehouse.update_attributes(inputs)
      @warehouse.save
      redirect_to(edit_warehouse_url(@warehouse), :notice => 'Data Gudang sukses di simpan.')
    else
      to_flash(@warehouse)
      render :action => "edit"
    end
  end

  def destroy
    @warehouse = Warehouse.find(params[:id])
    @warehouse.delete = true
    @warehouse.save
    redirect_to(warehouses_url)
  end  
  
  def enable
    @warehouse = Warehouse.find(params[:id])
    @warehouse.update_attributes(:enabled => true)
    redirect_to(warehouses_url)
  end
  
  def disable
    @warehouse = Warehouse.find(params[:id])
    @warehouse.update_attributes(:enabled => false)
    redirect_to(warehouses_url)
  end
end
