class TaxinvoiceattachmentsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "taxinvoices"
    @where = "taxinvoiceattachments"
  end

  def index
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
    @attachments = Taxinvoiceattachment.active.where("date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date.end_of_day).order("date desc")
    respond_to :html
  end

  def new
    @process = 'new'
    @attachment = Taxinvoiceattachment.new
    @attachment.date = Date.today

    if params[:customer_id].present? && params[:taxinvoice_id].present?
      @attachment.customer_id = params[:customer_id]
      @attachment.taxinvoice_id = params[:taxinvoice_id]
      taxinvoice_ids = Taxinvoice.joins("LEFT OUTER JOIN taxinvoiceattachments ON taxinvoices.id = taxinvoiceattachments.taxinvoice_id").where("taxinvoices.deleted = false AND taxinvoices.customer_id = ? AND taxinvoiceattachments.id IS NULL", params[:customer_id]).pluck("taxinvoices.id")
      taxinvoice_ids << @attachment.taxinvoice_id
      @taxinvoices = Taxinvoice.where("id in (?)", taxinvoice_ids).order("long_id desc")
    end

    @customers = Customer.where(:enabled => true, :deleted => false).where("name LIKE '%RDPI%' OR name LIKE '%PURA%' OR name LIKE '%INTI' OR id in (SELECT DISTINCT customer_id as id from taxinvoices WHERE customer_id is not null AND date BETWEEN current_date - interval '30' day AND current_date + interval '45' day)").order(:name)
    @types = Setting.find_by_name("Tipe Lampiran Invoice").value.split(",") rescue ["TO", "SPK", "STO"]
  end

  def edit
    @process = 'edit'
    @attachment = Taxinvoiceattachment.find(params[:id])
    @customers = Customer.where(:enabled => true, :deleted => false).where("name LIKE '%RDPI%' OR name LIKE '%PURA%' OR name LIKE '%INTI' OR id in (SELECT DISTINCT customer_id as id from taxinvoices WHERE customer_id is not null AND date BETWEEN current_date - interval '30' day AND current_date + interval '45' day)").order(:name)
    @types = Setting.find_by_name("Tipe Lampiran Invoice").value.split(",") rescue ['SO','STO','PO','TO']
    taxinvoice_ids = Taxinvoice.joins("LEFT OUTER JOIN taxinvoiceattachments ON taxinvoices.id = taxinvoiceattachments.taxinvoice_id").where("taxinvoices.deleted = false AND taxinvoices.customer_id = ? AND taxinvoiceattachments.id IS NULL", params[:customer_id]).pluck("taxinvoices.id")
    taxinvoice_ids << @attachment.taxinvoice_id
    @taxinvoices = Taxinvoice.where("id in (?)", taxinvoice_ids).order("long_id desc")
  end

  def create
    # render json: params[:attachment].inspect
    # return false
    taxinvoiceattachment = Taxinvoiceattachment.new(params[:taxinvoiceattachment])
    taxinvoiceattachment.user_id = current_user.id

    if taxinvoiceattachment.save
 
      redirect_to edit_taxinvoiceattachment_path(taxinvoiceattachment), :notice => 'Data berhasil disimpan.'
    else
      to_flash(taxinvoiceattachment)
      render :action => "new"
    end
  end

  def update
    taxinvoiceattachment = Taxinvoiceattachment.find(params[:id])
    taxinvoiceattachment.user_id = current_user.id
    taxinvoiceattachment.update_attributes(params[:taxinvoiceattachment])
 
    redirect_to edit_taxinvoiceattachment_path(taxinvoiceattachment), :notice => 'Data berhasil disimpan.'
  end

 def destroy
    attachment = Taxinvoiceattachment.find(params[:id])
    attachment.destroy

    flash[:notice] = 'Data berhasil dihapus'
    redirect_to taxinvoiceattachments_path(:startdate => attachment.date.strftime('%d-%m-%Y'), :enddate => attachment.date.strftime('%d-%m-%Y'))
  end

  def gettaxinvoicesbycustomer
    @taxinvoices = Taxinvoice.joins("LEFT OUTER JOIN taxinvoiceattachments ON taxinvoices.id = taxinvoiceattachments.taxinvoice_id").where("taxinvoices.deleted = false AND taxinvoices.customer_id = ? AND taxinvoiceattachments.id IS NULL", params[:customer_id]).order("long_id desc")
    render :json => {:success => true, :html => render_to_string(:partial => "taxinvoicesbycustomer"), :layout => false}.to_json;
  end
end
