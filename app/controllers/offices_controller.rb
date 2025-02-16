class OfficesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "masters"
    @where = "offices"
    @pagetitle = "Master Cabang"
    @provinces = [
      "Aceh",
      "Sumatera Utara",
      "Sumatera Barat",
      "Jambi",
      "Bengkulu",
      "Sumatera Selatan",
      "Lampung",
      "Banten",
      "DKI Jakarta",
      "Jawa Barat",
      "Jawa Tengah",
      "DIY (Yogyakarta)",
      "Jawa Timur",
      "Bali",
      "NTB",
      "NTT",
      "Riau"
    ]
    @attachments_category = ["Foto Kantor","Foto Jalan","Legalitas","Lainnya"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Admin Kendaraan, Admin Kontainer'
  end

  def index
    role = cek_roles @user_role
    if role
      @offices = Office.active
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def new
    @office = Office.new
    @office.enabled = true
    @process = 'new'
    respond_to :html
  end

  def edit
    @office = Office.find(params[:id])
    @process = 'edit'
    respond_to :html
  end

  def create
    inputs = params[:office]
    @office = Office.new(inputs)

    if @office.save
      redirect_to(offices_url(), :notice => 'Data Kantor sukses ditambah.')
    else
      redirect_to(new_office_url(), :notice => 'Data Kantor gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:office]
    @office = Office.find(params[:id])

    if @office.update(inputs)
      @office.save
      redirect_to(edit_office_url(@office), :notice => 'Data Kantor sukses disimpan.')
    else
      redirect_to(edit_office_url(@office), :notice => 'Data Kantor gagal disimpan. Data Harus Unik.')
    end
  end

  def destroy
    @office = Office.find(params[:id])
    @office.deleted = true
    @office.save
    redirect_to(offices_url)
  end  
  
  def enable
    @office = Office.find(params[:id])
    @office.update(:enabled => true)
    redirect_to(offices_url)
  end
  
  def disable
    @office = Office.find(params[:id])
    @office.update(:enabled => false)
    redirect_to(offices_url)
  end

  # private
  # def params
	#   {:office => params.fetch(:office, {}).permit(
  #     :enabled, :deleted, :name, :abbr, 
  #     :description,:latitude,:longitude,
  #     :address,:city,:province,:phone,
  #     :mobile,:garage
  #   )}
  # end
end


