class QuotationgroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "marketing"
    @where = "quotation"
    @customers = Customer.active.order('name asc')
  end

  def getcustomer
    @customers = Customer.active.order('name asc')
    render :json => { :success => true, :html => render_to_string(:partial => "quotationgroups/customer"), :layout => false };
  end

  def getquotation
    @quotations = Quotation.active.where(quotationgroup_id: params['id']).order(:name)
    # render json: params
    # return false
    render :json => { :success => true, :html => render_to_string(:partial => "quotationgroups/quotation"), :layout => false };
  end

  def index
    @offices = Office.active.order('id asc')
  end

  def index_api
    batas = 40
    halaman = params[:page].present? ? params[:page].to_i : 1
    halaman_awal = (halaman > 1) ? (halaman * batas) - batas : 0
    halaman_awal = halaman_awal + 1	
    additional_query = ""
    if params[:query].present?
      additional_query += " and name ~* '.*#{params[:query]}.*'"
    end
    if params[:customer_id].present? && params[:customer_id] != "all"
      additional_query += " and customer_id = #{params[:customer_id]}"
    end

    all_data = Quotationgroup.where("deleted = false#{additional_query}").select(:id).count()
    @quotationgroups = Quotationgroup.where("deleted = false#{additional_query} AND status != 'confirmed'").limit(batas).order("date asc").order("long_id asc")

    @total_page = (all_data.to_f / batas.to_f).ceil
    # render json: @quotationgroups.to_sql
    render partial: "table"
    
  end

  def indexconfirm
    @where = 'quotation-confirm'
    @offices = Office.active.order('name asc')
  end

  def indexconfirm_api
    batas = 40
    halaman = params[:page].present? ? params[:page].to_i : 1
    halaman_awal = (halaman > 1) ? (halaman * batas) - batas : 0
    halaman_awal = halaman_awal + 1	
    additional_query = ""
    if params[:query].present?
      additional_query += " and name ~* '.*#{params[:query]}.*'"
    end
    if params[:customer_id].present? && params[:customer_id] != "all"
      additional_query += " and customer_id = #{params[:customer_id]}"
    end

    all_data = Quotationgroup.where("deleted = false#{additional_query}").select(:id).count()
    @quotationgroups = Quotationgroup.where("deleted = false#{additional_query} AND status = 'confirmed'").limit(batas).order("long_id desc")

    @total_page = (all_data.to_f / batas.to_f).ceil
    # render json: @quotationgroups.to_sql
    render partial: "table"
    
  end

  def addnew
    @quotationgroup = Quotationgroup.new
    respond_to :html
  end

  def new
    @process = 'new'
    @quotationgroup = Quotationgroup.new
  end

  def edit
    @process = 'edit'
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotations = Quotation.active.where(quotationgroup_id: @quotationgroup.id)
    @logs = Quotationlog.where(quotation_id: params[:id]).order("created_at DESC")
  end

  def show
    @process = 'show'
    @where = 'quotation-confirm'
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotations = Quotation.active.where(quotationgroup_id: params['id']).order(:name)
  end

  def create
    inputs = params[:quotationgroup]
    @quotationgroup = Quotationgroup.new(inputs)
    @quotationgroup.enabled = true
    @quotationgroup.created_by = current_user.id

    if @quotationgroup.save
      redirect_to(edit_quotationgroup_url(@quotationgroup), :notice => 'Data Penawaran sukses ditambah.')
    else
      to_flash(@quotationgroup)
      render :action => "new"
    end
  end

  def update
    inputs = params[:quotationgroup]
    @quotationgroup = Quotationgroup.find(params[:id])

    if @quotationgroup.update_attributes(inputs)
      @quotationgroup.save
      redirect_to(edit_quotationgroup_path(params['id']), :notice => 'Data Penawaran sukses diupdate.')
    else
      to_flash(@quotationgroup)
      render :action => "edit"
    end
  end

  def destroy
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.deleted = true
    @quotationgroup.save
    redirect_to quotationgroups_url
  end
  
  def enable
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.update_attributes(:enabled => true)
    redirect_to (quotations_url)
  end
  
  def disable
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.update_attributes(:enabled => false)
    redirect_to (quotations_url)
  end

  def copy
    render json: params
  end

  def confirmation
    # render json: params
    # return false
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotations = Quotation.active.where(quotationgroup_id: params['id'])

    if params['newstatus'] == 'confirm'
      @quotationgroup.status = 'confirmed'
      @quotationgroup.confirmed_by = current_user.id
      @quotationgroup.rejected_by = nil
      @quotationgroup.confirmed_date = Time.new.strftime("%Y-%m-%d")

      if @quotationgroup.customer_id.blank?
        @customer = Customer.new
        @customer.name = @quotationgroup.customer_name
        @customer.save
      end

      @quotations.each do |quotation|
        @route = Route.new
        @routeloc = Routelocation.new
        
        if @quotationgroup.customer_id.blank?
          @route.customer_id = @customer.id
          @routeloc.customer_id = @customer.id
        else
          @route.customer_id = @quotationgroup.customer_id
          @routeloc.customer_id = @quotationgroup.customer_id
        end

        @route.name = quotation.name
        @route.distance = quotation.distance
        @route.price_per_type = quotation.price_per_type
        @route.routegroup_id = quotation.routegroup_id
        @route.price_per = quotation.price_per
        @route.transporttype = quotation.transporttype
        @route.office_id = quotation.office_id
        @route.commodity_id = quotation.commodity_id
        @route.quotation_id = quotation.id
        @route.description = quotation.description

        @route.save

        @routeloc.route_id = @route.id
        @routeloc.longitude_start = quotation.longitude_start
        @routeloc.latitude_start = quotation.latitude_start
        @routeloc.address_start = quotation.address_start
        @routeloc.longitude_end = quotation.longitude_end
        @routeloc.latitude_end = quotation.latitude_end
        @routeloc.address_end = quotation.address_end

        @routeloc.save
      end

    elsif params['newstatus'] == 'reject'
      @quotationgroup.status = 'rejected'
      @quotationgroup.rejected_by = current_user.id
    end

    @quotationgroup.notes = params['notes']
    @quotationgroup.save
    redirect_to(quotationgroups_url)
  end

  def print
    @where = 'quotation-confirm'
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotations = Quotation.active.where(quotationgroup_id: params[:id]).order(:price_per)
    @confirmation = User.find(@quotationgroup.confirmed_by)
    
    userroles = Userrole.where(user_id: @quotationgroup.confirmed_by).order(:role_id).first
    @confirmation_role = Role.find(userroles.role_id) rescue nil


    month = @quotationgroup.confirmed_date.strftime('%m')
    case month
    when '01'
      @month = 'Januari'
    when '02'
      @month = 'Februari'
    when '03'
      @month = 'Maret'
    when '04'
      @month = 'April'
    when '05'
      @month = 'Mei'
    when '06'
      @month = 'Juni'
    when '07'
      @month = 'Juli'
    when '08'
      @month = 'Agustus'
    when '09'
      @month = 'September'
    when '10'
      @month = 'Oktober'
    when '11'
      @month = 'November'
    when '12'
      @month = 'Desember'
    end
    # render json: @quotations.present?
    # return false
    
    respond_to :html
  end
end
