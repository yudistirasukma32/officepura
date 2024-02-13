class CommoditiesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "commodities"

    @industries = [
      ["Pilih Industri", nil],
      ["Industri Kimia", "Industri Kimia"],
      ["Industri Agri", "Industri Agri"],
      ["Industri Konsumer", "Industri Konsumer"],
      ["Lainnya", "Lainnya"]
    ]
  end

  def set_role
    @user_role = 'Admin Keuangan, Admin Marketing'
  end

  def index
    role = cek_roles @user_role
    if role
      @commodities = Commodity.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @commodity = Commodity.new
    @commodity.enabled = true
    respond_to :html
  end

  def edit
    @commodity = Commodity.find(params[:id])

    respond_to :html
  end

  def create
    inputs = params[:commodity]
    @commodity = Commodity.new(inputs)

    if @commodity.save
      redirect_to(commodities_url(), :notice => 'Data commodity sukses di tambah.')
    else
      to_flash(@commodity)
      render :action => "new"
    end
  end

  def update
    inputs = params[:commodity]
    @commodity = Commodity.find(params[:id])

    if @commodity.update_attributes(inputs)
      @commodity.save
      redirect_to(edit_commodity_url(@commodity), :notice => 'Data commodity sukses di simpan.')
    else
      to_flash(@commodity)
      render :action => "edit"
    end
  end

  def destroy
    @commodity = Commodity.find(params[:id])
    @commodity.deleted = true
    @commodity.save
    redirect_to(commodities_url)
  end

  def enable
    @commodity = Commodity.find(params[:id])
    @commodity.update_attributes(:enabled => true)
    redirect_to(commodities_url)
  end

  def disable
    @commodity = Commodity.find(params[:id])
    @commodity.update_attributes(:enabled => false)
    redirect_to(commodities_url)
  end
end
