class ContainermemosController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "transactions"
    @where = "containermemos"
    
    @contype = ["ISOTANK 20FT", "ISOTANK EMPTY 20FT", "DRY CONTAINER EMPTY 20FT", "DRY CONTAINER 20FT", "DRY CONTAINER EMPTY 40FT", "DRY CONTAINER 40FT"]
    
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan'
  end

  def index
    role = cek_roles @user_role
    if role
      @containermemos = Containermemo.all(:order =>:date)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @containermemo = Containermemo.new
    @containermemo.enabled = true
    respond_to :html
  end

  def edit
    @containermemo = Containermemo.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:containermemo]
    @containermemo = Containermemo.new(inputs)

    if @containermemo.save
      redirect_to(containermemos_url(), :notice => 'Data Memo Container sukses ditambah.')
    else
      to_flash(@containermemo)
      render :action => "new"
    end
  end

  def update
    inputs = params[:containermemo]
    @containermemo = Containermemo.find(params[:id])

    if @containermemo.update_attributes(inputs)
      @containermemo.save
      redirect_to(edit_container_url(@containermemo), :notice => 'Data Memo Container sukses disimpan.')
    else
      to_flash(@containermemo)
      render :action => "edit"
    end
  end

  def destroy
    @containermemo = Containermemo.find(params[:id])
    @containermemo.deleted = true
    @containermemo.save
    redirect_to(containermemos_url)
  end  
  
  def enable
    @containermemo = Containermemo.find(params[:id])
    @containermemo.update_attributes(:enabled => true)
    redirect_to(containermemos_url)
  end
  
  def disable
    @containermemo = Containermemo.find(params[:id])
    @containermemo.update_attributes(:enabled => false)
    redirect_to(containermemos_url)
  end
end
