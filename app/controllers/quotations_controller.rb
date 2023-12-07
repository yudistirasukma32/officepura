class QuotationsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "marketing"
    @where = "quotation"
    @price_per_types = ["KG", "LITER", "BORONGAN","M3"]
    @transporttypes = ["TRUK", "ISOTANK", "KERETA", "KAPAL (TOL LAUT)"]
    @customers = Customer.active.order('name asc')
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

    all_data = Quotation.where("deleted = false#{additional_query}").select(:id).count()
    @quotations = Quotation.where("deleted = false#{additional_query} AND status != 'confirmed'").limit(batas).order("name asc")

    @total_page = (all_data.to_f / batas.to_f).ceil
    # render json: @quotations.to_sql
    render partial: "table"
    
  end

  def indexconfirm
    @where = 'quotation-confirm'
    @offices = Office.active.order('id asc')
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

    all_data = Quotation.where("deleted = false#{additional_query}").select(:id).count()
    @quotations = Quotation.where("deleted = false#{additional_query} AND status = 'confirmed'").limit(batas).order("name asc")

    @total_page = (all_data.to_f / batas.to_f).ceil
    # render json: @quotations.to_sql
    render partial: "table"
    
  end

  def addnew
    @quotation = Quotation.new
    respond_to :html
  end

  def new
    @process = 'new'
    @quotation = Quotation.new
    @quotationgroup = Quotationgroup.find(params['format'])
  end

  def edit
    @process = 'edit'
    @quotation = Quotation.find(params[:id])
    @logs = Quotationlog.where(quotation_id: params[:id]).order("created_at DESC")
    @quotationgroup = Quotationgroup.find(@quotation.quotationgroup_id)
  end

  def show
    @process = 'show'
    @where = 'quotation-confirm'
    @quotation = Quotation.find(params[:id])
  end

  def create
    inputs = params[:quotation]
    @quotation = Quotation.new(inputs)
    @quotation.enabled = true
    @quotationgroup = Quotationgroup.find(inputs['quotationgroup_id'])

    if @quotationgroup.status == 'rejected'
      @quotationgroup.status = 'unconfirmed'
      @quotationgroup.save
    end
    
    if checkrole 'Marketing, Admin Marketing'
      @quotation.price_per = inputs[:price_per].delete('.').gsub(",",".") || 0
    else
      @quotation.price_per = 0
    end

    if @quotation.save
      redirect_to(edit_quotation_url(@quotation), :notice => 'Data Penawaran sukses ditambah.')
    else
      to_flash(@quotation)
      render :action => "new"
    end
  end

  def update
    inputs = params[:quotation]
    @quotation = Quotation.find(params[:id])
    @quotationgroup = Quotationgroup.find(@quotation.quotationgroup_id)
    @log = Quotationlog.new
    
    @log.old_price_per = @quotation.price_per

    if @quotationgroup.status == 'rejected'
      @quotationgroup.status = 'unconfirmed'
      @quotationgroup.save
    end

    if @quotation.update_attributes(inputs)
      
      if checkrole 'Marketing, Admin Marketing'
        @quotation.price_per = inputs[:price_per].delete('.').gsub(",",".") || 0
      end

      @log.quotation_id = @quotation.id
      @log.updated_by = current_user.id
      @log.name = @quotation.name
      @log.description = inputs[:description]
      @log.new_price_per = @quotation.price_per

      @log.save
      @quotation.save
      redirect_to(edit_quotationgroup_path(@quotation.quotationgroup_id), :notice => 'Data Penawaran sukses diupdate.')
    else
      to_flash(@quotation)
      render :action => "edit"
    end
  end

  def destroy
    @quotation = Quotation.find(params[:id])
    customer_id = @quotation.customer_id
    @quotation.destroy
    redirect_to quotations_url
  end  
  
  def enable
    @quotation = Quotation.find(params[:id])
    @quotation.update_attributes(:enabled => true)
    redirect_to (quotations_url)
  end
  
  def disable
    @quotation = Quotation.find(params[:id])
    @quotation.update_attributes(:enabled => false)
    redirect_to (quotations_url)
  end

  def copy
    render json: params
  end
end
