class ContainersController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:get_container_pura]

  def set_section
    @section = "masters"
    @where = "containers"
    @categories = ["BELI", "SEWA", "FREEUSE"]
    @groups = ["DRY CONTAINER 20FT", "DRY CONTAINER 40FT", "SIDE DOOR CONTAINER 20FT", "SIDE DOOR CONTAINER 40FT"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan, Admin Kontainer'
  end

  def index
    role = cek_roles @user_role
    if role
      @containers = Container.all(:order =>:containernumber)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @container = Container.new
    @container.enabled = true
    respond_to :html
  end

  def edit
    @container = Container.find(params[:id])

    respond_to :html
  end

  def create
    inputs = params[:container]
    @container = Container.new(inputs)

    if @container.save
      redirect_to(containers_url(), :notice => 'Data Container sukses ditambah.')
    else
      redirect_to(new_container_url(), :notice => 'Data Container gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:container]
    @container = Container.find(params[:id])

    if @container.update_attributes(inputs)
      @container.save
      redirect_to(edit_container_url(@container), :notice => 'Data Container sukses disimpan.')
    else
      redirect_to(edit_container_url(@container), :notice => 'Data Container gagal diedit. Data Harus Unik.')
    end
  end

  def destroy
    @container = Container.find(params[:id])
    @container.deleted = true
    @container.save
    redirect_to(containers_url)
  end  
  
  def enable
    @container = Container.find(params[:id])
    @container.update_attributes(:enabled => true)
    redirect_to(containers_url)
  end
  
  def disable
    @container = Container.find(params[:id])
    @container.update_attributes(:enabled => false)
    redirect_to(containers_url)
  end

  def get_container_pura
		@containers = Container.order('containernumber').where('deleted = false')
		count_container = @containers.count

		@containerlist = @containers.map do |c|
			{
				:id => c.id,
				:enabled => c.enabled,
				:containernumber => c.containernumber,
				:category => c.category,
				:vendor_id => c.vendor_id,
				:origin_company => 'Office PURA',
				:origin_id => c.id
			}
		end

		render json: {
			message: 'Success',
			status: 200,
			count: count_container,
			containers: @containerlist,
			}, status: 200
  end
end