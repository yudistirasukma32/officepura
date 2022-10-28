class AssetgroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
    @where = "assetgroups"
    @asset_types = ["Lancar", "Tidak Lancar"]
  end

  def index
    @assetgroups = Assetgroup.all(:order => :name)
    respond_to :html
  end

  def new
    @assetgroup = Assetgroup.new
  end

  def edit
    @assetgroup = Assetgroup.find(params[:id])
  end

  def create
    inputs = params[:assetgroup]
    @assetgroup = Assetgroup.new(inputs)

    if @assetgroup.save
      redirect_to(edit_assetgroup_url(@assetgroup), :notice => 'Data Aktiva sukses di tambah.')
    else
      to_flash(@assetgroup)
      render :action => "new"
    end
  end

  def update
    inputs = params[:assetgroup]
    @assetgroup = Assetgroup.find(params[:id])

    if @assetgroup.update_attributes(inputs)
      @assetgroup.save
      redirect_to(edit_assetgroup_url(@assetgroup), :notice => 'Data Aktiva sukses di simpan.')
    else
      to_flash(@assetgroup)
      render :action => "edit"
    end
  end

  def destroy
    @assetgroup = Assetgroup.find(params[:id])
    @assetgroup.deleted = true
    @assetgroup.save
    redirect_to(assetgroups_url)
  end  
end