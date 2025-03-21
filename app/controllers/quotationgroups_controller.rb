class QuotationgroupsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "quotation"
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

    @month = params[:month]
    @month = "%02d" % Date.today.month.to_s if @month.nil?
    @year = params[:year]
    @year = Date.today.year if @year.nil?

    @offices = Office.active.order('id asc')

  end

  def index_api
    batas = 40
    halaman = params[:page].present? ? params[:page].to_i : 1
    halaman_awal = (halaman > 1) ? (halaman * batas) - batas : 0
    # halaman_awal = halaman_awal + 1
    additional_query = ""
    
    if params[:query].present?
      additional_query += " and name ~* '.*#{params[:query]}.*'"
    end

    if params[:customer_id].present? && params[:customer_id] != "all"
      additional_query += " and customer_id = #{params[:customer_id]}"
    end

    all_data = Quotationgroup.where("deleted = false#{additional_query}").select(:id).count()
    @quotationgroups = Quotationgroup.where("deleted = false#{additional_query}").limit(batas).offset(halaman_awal).order("date DESC").order("long_id asc")

    if params[:month].present? && params[:year].present?
      @quotationgroups = @quotationgroups.where("to_char(date, 'MM-YYYY') = ?", "#{params[:month]}-#{params[:year]}")
      all_data = @quotationgroups.select(:id).count()
    end

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
    @quotationgroups = Quotationgroup.where("deleted = false#{additional_query} AND status = 'confirmed'").limit(batas).order("date desc").order("long_id desc")

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

    @attachments_category = ['Tanda Tangan PIC', 'KTP PIC', 'NPWP PIC', 'Surat Kesepakatan', 'Salinan Penawaran', 'MoU', 'Lain-lain']

    @quotationgroup = Quotationgroup.find(params[:id])
    @quotations = Quotation.active.where(quotationgroup_id: @quotationgroup.id)
    @logs = Quotationlog.where('quotation_id IN (?)', @quotations.pluck(:id)).order("created_at DESC")

    @confirmation = User.find(@quotationgroup.created_by)

    if @confirmation.username == 'lilis'
    @marketing_phone = '087773330590'
    elsif @confirmation.username == 'anindya'
    @marketing_phone = '082234451234'
    elsif @confirmation.username == 'finca'
    @marketing_phone = '082234451234'
    end

    if @quotationgroup.confirmed_date.present?
      month = @quotationgroup.confirmed_date.strftime('%m')
    else
      month = @quotationgroup.date.strftime('%m')
    end

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
    @confirmation = User.find(@quotationgroup.created_by)

    if @confirmation.username == 'lilis'
    @marketing_phone = '087773330590'
    elsif @confirmation.username == 'anindya'
    @marketing_phone = '082234451234'
    elsif @confirmation.username == 'finca'
    @marketing_phone = '082234451234'
    end

    # userroles = Userrole.where(user_id: @quotationgroup.created_by).order(:role_id).first
    # @confirmation_role = Role.find(userroles.role_id) rescue nil
    @confirmation_role = 'Marketing'

    if @quotationgroup.confirmed_date.present?
      month = @quotationgroup.confirmed_date.strftime('%m')
    else
      month = @quotationgroup.date.strftime('%m')
    end

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

  def approve_review
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.reviewed = true
    @quotationgroup.reviewed_at = Time.new.strftime("%Y-%m-%d")
    @quotationgroup.reviewed_by = current_user.id
    @quotationgroup.save
    redirect_to(edit_quotationgroup_path(params['id']), :notice => 'Data Penawaran sukses direview.')
  end

  def approve_confirm
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.confirmed = true
    @quotationgroup.confirmed_at = Time.new.strftime("%Y-%m-%d")
    @quotationgroup.confirmed_by = current_user.id
    @quotationgroup.save
    redirect_to(edit_quotationgroup_path(params['id']), :notice => 'Data Penawaran sukses dikonfirmasi.')
  end

  def approve_sent
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.is_sent = true
    @quotationgroup.sent_date = Time.new.strftime("%Y-%m-%d")
    @quotationgroup.save
    redirect_to(edit_quotationgroup_path(params['id']), :notice => 'Data Penawaran sukses dikirim.')
  end

  def approve_customer
    @quotationgroup = Quotationgroup.find(params[:id])
    @quotationgroup.customer_approved = true
    @quotationgroup.customer_approved_date = Time.new.strftime("%Y-%m-%d")
    @quotationgroup.save

    @quotations = Quotation.active.where('quotationgroup_id = ?', params[:id])
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
    
    redirect_to(edit_quotationgroup_path(params['id']), :notice => 'Data Penawaran sukses disetujui customer.')
  end

  def reports
    @month = params.fetch(:month, Date.today.strftime('%m'))
    @year = params.fetch(:year, Date.today.year.to_s)
  
    @quotationgroups = Quotationgroup.where(deleted: false).order('date ASC')
  
    # Filter by month & year
    @quotationgroups = @quotationgroups.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}")
  
    # Filter by customer_id (if not "all")
    if params[:customer_id].present? && params[:customer_id] != "all"
      @quotationgroups = @quotationgroups.where(customer_id: params[:customer_id])
    end
  
    # Apply status filtering
    if params[:status].present?
      status_filter = case params[:status]
                      when 'Disetujui' then { customer_approved: true }
                      when 'Dikirim' then { is_sent: true, customer_approved: false }
                      when 'Terkonfirmasi' then { confirmed: true, is_sent: false }
                      when 'Sudah Review' then { reviewed: true, confirmed: false }
                      when 'Draft' then { customer_approved: false, is_sent: false, confirmed: false, reviewed: false }
                      else nil
                      end
  
      @quotationgroups = @quotationgroups.where(status_filter) if status_filter
    end
  
    # Count total records after filtering
    @all_data = @quotationgroups.count
  end  
  
end
