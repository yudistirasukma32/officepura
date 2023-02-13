class StaffsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "staffs"
    @statuses = ["Tetap", "Kontrak", "Resign"]
  end

  def set_role
    @user_role = 'Admin HRD'
  end

  def index
    role = cek_roles @user_role
    if role

      @status = params[:status]

      @staffs = Staff.order('name')

      if @status.present? and @status != ''
          @staffs = @staffs.where("status = ?", @status)
      end

      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def new
    @staff = Staff.new
    @staff.enabled = true
  end

  def edit
    @staff = Staff.find(params[:id])
    @staff.salary = @staff.salary.to_i
    @staff.driver_licence_expiry = @staff.driver_licence_expiry.strftime('%d-%m-%Y') if !@staff.driver_licence_expiry.blank?
    @staff.id_card_expiry = @staff.id_card_expiry.strftime('%d-%m-%Y') if !@staff.id_card_expiry.blank?
    @staff.start_working = @staff.start_working.strftime('%d-%m-%Y') if !@staff.start_working.blank?
  end

  def create
    inputs = params[:staff]
    @staff = Staff.new(inputs)
    @staff.email = @staff.email.downcase

    if @staff.save
      redirect_to(edit_staff_url(@staff), :notice => 'Data Staff sukses di tambah.')
    else
      to_flash(@staff)
      render :action => "new"
    end
  end

  def update
    inputs = params[:staff]
    @staff = Staff.find(params[:id])

    if @staff.update_attributes(inputs)
      @staff.email = @staff.email.downcase
      @staff.save
      redirect_to(edit_staff_url(@staff), :notice => 'Data Staff sukses di simpan.')
    else
      to_flash(@staff)
      render :action => "edit"
    end
  end

  def destroy
    @staff = Staff.find(params[:id])
    @staff.deleted = true
    @staff.save 
    redirect_to(staffs_url)
  end  
  
  def enable
    @staff = Staff.find(params[:id])
    @staff.update_attributes(:enabled => true)
    redirect_to(staffs_url)
  end
  
  def disable
    @staff = Staff.find(params[:id])
    @staff.update_attributes(:enabled => false)
    redirect_to(staffs_url)
  end
end
