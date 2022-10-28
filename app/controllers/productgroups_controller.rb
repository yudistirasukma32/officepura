class ProductgroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
    @where = "productgroups"
  end

  def index
    @productgroups = Productgroup.all(:order => :name)
    respond_to :html
  end

  def new
    @productgroup = Productgroup.new
    @productgroup.enabled = true
  end

  def edit
    @productgroup = Productgroup.find(params[:id])
  end

  def create
    inputs = params[:productgroup]
    @productgroup = Productgroup.new(inputs)

    if @productgroup.save
      redirect_to(edit_productgroup_url(@productgroup), :notice => 'Grup Barang sukses di tambah.')
    else
      to_flash(@productgroup)
      render :action => "new"
    end
  end

  def update
    inputs = params[:productgroup]
    @productgroup = Productgroup.find(params[:id])

    if @productgroup.update_attributes(inputs)
      @productgroup.save
      redirect_to(edit_productgroup_url(@productgroup), :notice => 'Grup Barang sukses di simpan.')
    else
      to_flash(@productgroup)
      render :action => "edit"
    end
  end

  def destroy
    @productgroup = Productgroup.find(params[:id])
    @productgroup.deleted = true
    @productgroup.save
    redirect_to(productgroups_url)
  end  
  
  def enable
    @productgroup = Productgroup.find(params[:id])
    @productgroup.update_attributes(:enabled => true)
    redirect_to(productgroups_url)
  end
  
  def disable
    @productgroup = Productgroup.find(params[:id])
    @productgroup.update_attributes(:enabled => false)
    redirect_to(productgroups_url)
  end
end
