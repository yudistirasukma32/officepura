class HelpersController < ApplicationController
	include ApplicationHelper
	layout "application"
  protect_from_forgery :except => [:create, :update]
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "helpers"
    @statuses = ["Tetap", "Warnen"]
    @attachments_category = ["KTP", "FOTO", "BPJS", "SIM", "NPWP", "Lainnya"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin HRD, Admin Keuangan, Operasional BKK, Vendor Kernet, Admin Kernet'
    @vendor = 'Vendor Kernet'
  end

  def index
    role = cek_roles @user_role
    if role

      vendor_role = checkroleonly @vendor

      if vendor_role

        @vendor = Vendor.where('user_id = ?', current_user.id)
        
        if @vendor.present?
          @helpers = Helper.order('name')
          @helpers = @helpers.where("vendor_id = ?", @vendor[0].id)
        end

      else

        @origin = params[:origin]
        @is_resign = params[:is_resign]
  
        @helpers = Helper.where('blacklist = false').order('name')
  
        if @origin.present? and @origin != ''
            @helpers = @helpers.where("origin = ?", @origin)
        end
  
        if @is_resign.present? and @is_resign != 'No'
            @helpers = @helpers.where("is_resign = true")
        end
  
        if @is_resign.present? and @is_resign == 'No'
          @helpers = @helpers.where("is_resign = false")
        end
  
          
      end

      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def new
    @process = 'new'
    @helper = Helper.new
    @helper.enabled = true
    @helper.weight_loss = @helper.weight_loss.to_i
    @helper.accident = @helper.accident.to_i
    @helper.sparepart = @helper.sparepart.to_i
    @helper.bon = @helper.bon.to_i
    @helper.saving = @helper.saving.to_i
    @vehicles = Vehicle.where("id not in (select vehicle_id from drivers where deleted = false) and deleted = false").order(:current_id)
  end

  def edit
    @process = 'edit'
    @helper = Helper.find(params[:id])
 
    @helper.salary = @helper.salary.to_i
    @helper.salary = @helper.salary.to_i
    @helper.weight_loss = @helper.weight_loss.to_i
    @helper.accident = @helper.accident.to_i
    @helper.sparepart = @helper.sparepart.to_i
    @helper.bon = @helper.bon.to_i
    @helper.saving = @helper.saving.to_i
    @helper.driver_licence_expiry = @helper.driver_licence_expiry.strftime('%d-%m-%Y') if !@helper.driver_licence_expiry.blank?
    @helper.id_card_expiry = @helper.id_card_expiry.strftime('%d-%m-%Y') if !@helper.id_card_expiry.blank?

    # render json: @helper.bank_account
  end

  def create_bank_expense_group
    # Bankexpensegroup.
    Helper.active.each do |helper|
      bank_expense_group = Bankexpensegroup.create({
        name: "Bank Kernet #{helper.name}",
        bankexpensegroup_id: 137
      })

      helper.bankexpensegroup_id = bank_expense_group.id
      helper.save
    end
  end

  def create
    inputs = params[:helper]
    @helper = Helper.new(inputs)

    @helper.is_resign = inputs[:is_resign] == "1" ? true : false
    @helper.blacklist = inputs[:blacklist] == "1" ? true : false

    if @helper.save
      if @helper.blacklist
        redirect_to(edit_helper_url(@helper, blacklist: 1), :notice => 'Data Kernet Daftar Hitam sukses ditambah.')
      
      else
      
        redirect_to(edit_helper_url(@helper), :notice => 'Data Kernet sukses ditambah.')
      
      end

    else
      to_flash(@helper, :notice => 'Data Kernet gagal ditambah')
      render :action => "new"
    end
  end

  def update
    inputs = params[:helper]
    @helper = Helper.find(params[:id])

    @helper.is_resign = inputs[:is_resign] == "1" ? true : false

    if @helper.update_attributes(inputs)

      @helper.save
      redirect_to(edit_helper_url(@helper), :notice => 'Data Kernet sukses disimpan.')
    else
      to_flash(@helper, :notice => 'Data Kernet gagal disimpan')
      render :action => "edit"
    end
  end

  def destroy
    @helper = Helper.find(params[:id])
    @helper.deleted = true
    @helper.save
    redirect_to(helpers_url)
  end  

  def blacklist
    role = cek_roles @user_role
    if role

      @origin = params[:origin]
      @is_resign = params[:is_resign]

      @helpers = Helper.blacklisted.order('name')

      if @origin.present? and @origin != ''
          @helpers = @helpers.where("origin = ?", @origin)
      end

      if @is_resign.present? and @is_resign != 'No'
          @helpers = @helpers.where("is_resign = true")
      end

      if @is_resign.present? and @is_resign == 'No'
        @helpers = @helpers.where("is_resign = false")
      end

      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def blacklisted
    @driver = Driver.find(params[:id])
    @driver.update_attributes(:blacklist => true)
    redirect_to(edit_driver_url(@driver, blacklist: 1), :notice => 'Data Supir Daftar Hitam sukses ditambah.')
  end

  def whitelisted
    @driver = Driver.find(params[:id])
    @driver.update_attributes(:blacklist => false)
    redirect_to(edit_driver_url(@driver), :notice => 'Data Supir sukses diupdate.')
  end

 
  
end
