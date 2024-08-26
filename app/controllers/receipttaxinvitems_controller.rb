class ReceipttaxinvitemsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "taxinvoiceitems"
    @where = "receipttaxinvitems"
  end

  def index
    @startdate = params[:startdate] || Date.today.at_beginning_of_month.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
    @receipts = Receipttaxinvitem.active.where("to_char(created_at, 'DD-MM-YYYY') BETWEEN ? AND ?", @startdate, @enddate).order("created_at desc")
    respond_to :html
  end

  def create_receipt
    # render json: {params: params, message: 'Sukses'}
    # return false
    if params[:receiptitem_id].present?
      receipt = Receipttaxinvitem.new
      receipt.user_id = current_user.id
      receipt.save

      params[:receiptitem_id].each do |item|
        item = Taxinvoiceitem.find(item)
        item.receipttaxinvitem_id = receipt.id
        item.save
      end

      render json: {status: 200, message: 'Tanda Terima SJ berhasil dibuat'}
    else
      render json: {status: 500, message: 'Tidak ada item yang dipilih'}
    end
  end

  def create_receiptinvoice
    invoice = Invoice.find(params[:invoice_id])

    if invoice.present?
      receipt = Receipttaxinvitem.new
      receipt.user_id = current_user.id
      receipt.save

      invoice.taxinvoiceitems.each do |item|
        item.receipttaxinvitem_id = receipt.id
        item.save
      end

      flash[:success] = 'Tanda Terima SJ berhasil dibuat'
      flash.keep
      redirect_to "/taxinvoiceitems/new/#{invoice.id}"
    end
  end

  def update_receipt
    receipt = Receipttaxinvitem.find(params[:id])
    time = receipt.created_at.strftime('%H:%M:%S')
    receipt.created_at = params[:created_at] + ' ' + time if params[:created_at].present?
    receipt.printdate = params[:printdate] if params[:printdate].present?

    if receipt.save
      render json: { status: 200, message: "Data berhasil disimpan.".html_safe }, status: 200
    else
      render json: { status: 400, message: "Data Invoice gagal diupdate" }, status: 400
    end
  end

 def destroy
    receipt = Receipttaxinvitem.find(params[:id])
    receipt.taxinvoiceitems.delete_all
    receipt.deleted = true
    receipt.deleteuser_id = current_user.id
    receipt.save

    flash[:notice] = 'Data berhasil dihapus'
    redirect_to receipttaxinvitems_path(:startdate => receipt.created_at.strftime('%d-%m-%Y'), :enddate => receipt.created_at.strftime('%d-%m-%Y'))
  end

  def print
    @receipt = Receipttaxinvitem.find(params[:id])
  end

  def update_printdate
    receipt = Receipttaxinvitem.find(params[:id])
    receipt.printdate = Date.today
    receipt.printuser_id = current_user.id
    receipt.save
    render :json => { :success => true,  :printdate => receipt.printdate }.to_json;
  end
end
