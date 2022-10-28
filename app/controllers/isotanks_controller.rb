class IsotanksController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "isotanks"
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role
      @isotanks = Isotank.all(:order =>:isotanknumber)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @isotank = Isotank.new
    @isotank.enabled = true
    respond_to :html
  end

  def edit
    @isotank = Isotank.find(params[:id])

    respond_to :html
  end

  def create
    inputs = params[:isotank]
    @isotank = Isotank.new(inputs)

    if @isotank.save
      redirect_to(isotanks_url(), :notice => 'Data Isotank sukses ditambah.')
    else
      redirect_to(new_isotank_url(), :notice => 'Data Isotank gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:isotank]
    @isotank = Isotank.find(params[:id])

    if @isotank.update_attributes(inputs)
      @isotank.save
      redirect_to(edit_isotank_url(@isotank), :notice => 'Data Isotank sukses disimpan.')
    else
      redirect_to(edit_isotank_url(@isotank), :notice => 'Data Isotank gagal disimpan. Data Harus Unik.')
    end
  end

  def destroy
    @isotank = Isotank.find(params[:id])
    @isotank.deleted = true
    @isotank.save
    redirect_to(isotanks_url)
  end  
  
  def enable
    @isotank = Isotank.find(params[:id])
    @isotank.update_attributes(:enabled => true)
    redirect_to(isotanks_url)
  end
  
  def disable
    @isotank = Isotank.find(params[:id])
    @isotank.update_attributes(:enabled => false)
    redirect_to(isotanks_url)
  end
end
