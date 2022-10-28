class AssetsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "assets"
    @asset_types = ["Lancar", "Tidak Lancar"]
  end

  def set_role
    @user_role = 'Admin Keuangan'
  end

  def index
    role = cek_roles @user_role
    if role
      @assets = Asset.all(:order => :name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @asset = Asset.new
    @asset.amount = @asset.amount.to_i
    @asset.enabled = true
  end

  def edit
    @asset = Asset.find(params[:id])

    @asset.amount = @asset.amount.to_i
    @asset.date_purchase = @asset.date_purchase.strftime('%d-%m-%Y') if !@asset.date_purchase.blank?
  end

  def create
    inputs = params[:asset]
    @asset = Asset.new(inputs)

    if @asset.save
      redirect_to(edit_asset_url(@asset), :notice => 'Data Aktiva sukses di tambah.')
    else
      to_flash(@asset)
      render :action => "new"
    end
  end

  def update
    inputs = params[:asset]
    @asset = Asset.find(params[:id])

    if @asset.update_attributes(inputs)
      @asset.save
      redirect_to(edit_asset_url(@asset), :notice => 'Data Aktiva sukses di simpan.')
    else
      to_flash(@asset)
      render :action => "edit"
    end
  end

  def destroy
    @asset = Asset.find(params[:id])
    @asset.deleted = true
    @asset.save
    redirect_to(assets_url)
  end  
  
  def enable
    @asset = Asset.find(params[:id])
    @asset.update_attributes(:enabled => true)
    redirect_to(assets_url)
  end
  
  def disable
    @asset = Asset.find(params[:id])
    @asset.update_attributes(:enabled => false)
    redirect_to(assets_url)
  end
end
