class ClaimmemosController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section
	# before_filter :set_claimmemo, only: [:edit, :update, :destroy]

  respond_to :html
	
	def set_section
    @section = "taxinvoices"
    @where = "claimmemos"
  end

  def index
    # @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil? 

    @invoice_id = params[:invoice_id] || ''

    @customer_id = params[:customer_id] || ''

    @office_id = params[:office_id] || ''

    @claimmemos = Claimmemo.active.where('claimmemos.date between ? and ?', @startdate.to_date, @enddate.to_date).order(:date)

    if !@customer_id.blank?
      @claimmemos = @claimmemos.joins(:invoice).where('invoices.customer_id = ? ', params[:customer_id])
    end

    if !@office_id.blank?
      @claimmemos = @claimmemos.joins(:invoice).where('invoices.office_id = ? ', params[:office_id])
    end

    if !@invoice_id.blank?
      @claimmemos = Claimmemo.active.where('deleted = false and invoice_id = ? ', params[:invoice_id])
    end

    respond_with(@claimmemos)
  end

  def new

    @process = 'new'

    @invoice_id = params[:invoice_id]

    if @invoice_id.blank?
      @invoice = Invoice.find(@invoice_id) rescue nil
      # @errors["invoice"] = "BKK harus diisi."
    else
      @invoice = Invoice.find(@invoice_id) rescue nil

      @taxinvoiceitems = Taxinvoiceitem.where("invoice_id = #{@invoice.id} AND deleted = FALSE") rescue nil

      if @invoice.nil?

        @errors["invoice"] = "BKK No. '#{zeropad(@invoice_id)}' tidak terdaftar."
      
      else

        @claimmemo = Claimmemo.new
        @claimmemo.date = Date.today.strftime('%d-%m-%Y')
        @claimmemo.weight_gross = @taxinvoiceitems.first.weight_gross rescue 0
        @claimmemo.weight_net = @taxinvoiceitems.first.weight_net rescue 0
        @claimmemo.shrink = @claimmemo.weight_gross - @claimmemo.weight_net
        @claimmemo.shrink_tolerance_percent = 0.3
        tolerance_total = (@claimmemo.weight_gross * @claimmemo.shrink_tolerance_percent / 100).floor
        @claimmemo.tolerance_total = tolerance_total
        shrinkage_load = (@claimmemo.shrink - tolerance_total).floor
        @claimmemo.shrinkage_load = shrinkage_load
      end

    end

    respond_with(@claimmemo)
  end

  def edit

    @process = 'edit'

    @claimmemo = Claimmemo.find(params[:id])
    @invoice_id = @claimmemo.invoice_id

    if @invoice_id.blank?
      @errors["invoice"] = "BKK harus diisi."
    else
      @invoice = Invoice.find(@invoice_id) rescue nil
      @taxinvoiceitems = Taxinvoiceitem.where("invoice_id = #{@invoice.id} AND deleted = FALSE") rescue ni;
    end

  	respond_with(@claimmemo)
  end

  def create
    @claimmemo = Claimmemo.new(params[:claimmemo])
    @claimmemo.user_id = current_user.id

    if @claimmemo.save
      redirect_to(claimmemos_path, :notice => 'Data sukses disimpan')
    else
      to_flash(@claimmemo, :notice => 'Data gagal disimpan')
    end
  end

  def update
    @claimmemo = Claimmemo.find(params[:id])

    if @claimmemo.update_attributes(params[:claimmemo])
      @claimmemo.save
      # redirect_to(claimmemos_path, :notice => 'Data sukses diupdate')
      redirect_to(edit_claimmemo_url(@claimmemo), :notice => 'Data sukses diupdate.')
    else
      to_flash(@claimmemo, :notice => 'Data gagal diupdate')
      render :action => "edit"
    end
  end

  def destroy
    @claimmemo = Claimmemo.find(params[:id])
    @claimmemo.deleted = true
    @claimmemo.save
		redirect_to(claimmemos_path, :notice => 'Data sukses dihapus')
  end

  def spv_approve
    inputs = params[:claimmemo]
    @claimmemo = Claimmemo.find(params[:id])

    if @claimmemo.update_attributes(inputs)
 
      @claimmemo.approved = true
      @claimmemo.approved_at = Time.now

      @claimmemo.save
      redirect_to(edit_claimmemo_url(@claimmemo), :notice => 'Data Klaim sukses di-approve.')
    else
      flash[:alert] = "Terjadi Kesalahan"
      render :action => "edit"
    end
  end

  def marketing_approve
    inputs = params[:claimmemo]
    @claimmemo = Claimmemo.find(params[:id])

    if @claimmemo.update_attributes(inputs)
 
      @claimmemo.approved_marketing = true

      @claimmemo.save
      redirect_to(edit_claimmemo_url(@claimmemo), :notice => 'Data Klaim sukses di-approve.')
    else
      flash[:alert] = "Terjadi Kesalahan"
      render :action => "edit"
    end
  end

  def load_approve
    inputs = params[:claimmemo]
    @claimmemo = Claimmemo.find(params[:id])

    if @claimmemo.update_attributes(inputs)
 
      @claimmemo.approved_load_spv = true

      @claimmemo.save
      redirect_to(edit_claimmemo_url(@claimmemo), :notice => 'Data Klaim sukses di-approve.')
    else
      flash[:alert] = "Terjadi Kesalahan"
      render :action => "edit"
    end
  end

  def unload_approve
    inputs = params[:claimmemo]
    @claimmemo = Claimmemo.find(params[:id])

    if @claimmemo.update_attributes(inputs)
 
      @claimmemo.approved_unload_spv = true

      @claimmemo.save
      redirect_to(edit_claimmemo_url(@claimmemo), :notice => 'Data Klaim sukses di-approve.')
    else
      flash[:alert] = "Terjadi Kesalahan"
      render :action => "edit"
    end
  end

  def gm_approve
    inputs = params[:claimmemo]
    @claimmemo = Claimmemo.find(params[:id])

    if @claimmemo.update_attributes(inputs)
 
      @claimmemo.approved_by_gm = true
      @claimmemo.approved_by_gm_at = Time.now

      @claimmemo.save
      redirect_to(edit_claimmemo_url(@claimmemo), :notice => 'Data Klaim sukses di-approve.')
    else
      flash[:alert] = "Terjadi Kesalahan"
      render :action => "edit"
    end
  end

  # private
  #   def set_claimmemo
  #     @claimmemo = Claimmemo.find(params[:id])
  #   end

  #   def params
  #     {:claimmemo => params.fetch(:claimmemo, {}).permit(
  #     :deleted, :enabled, :invoice_id, :taxinvoiceitem_id,
  #     :date, :vehicle_number, :weight_gross, :weight_net, :shrink,
  #     :description, :user_id, :deleteuser_id, :approved, :approved_by_gm,
  #     :approved_at, :approved_by_gm_at, 
  #     :shrink_tolerance_percent, :shrink_tolerance_money,
  #     :price_per, :total, :shrinkage_load, :tolerance_total,
  #     :discount_amount, :is_train, 
  #     :approved_marketing, :approved_load_spv, :approved_unload_spv
  #     )}
  #   end
end

