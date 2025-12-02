class ReceipttaxinvoicesController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "taxinvoices"
    @where = "receipttaxinvoices"
  end

  def index
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
    @receipttaxinvoices = Receipttaxinvoice.active.where("created_at BETWEEN ? AND ?", @startdate.to_datetime, @enddate.to_datetime.end_of_day).order("created_at desc")
    respond_to :html
  end

  def create
    raise "Pilih invoice terlebih dahulu" if params[:taxinvoice_ids].blank?

    ActiveRecord::Base.transaction do
      @receipt = Receipttaxinvoice.new(receipt_params)
      @receipt.user_id = current_user.id
      @receipt.save!

      Taxinvoice.where(id: params[:taxinvoice_ids])
                .update_all(receipttaxinvoice_id: @receipt.id)
    end

    redirect_to "/reports/unpaid_invoice",
                notice: "Receipt berhasil dibuat!"
  rescue => e
    redirect_back fallback_location: "/reports/unpaid_invoice", alert: e.message
  end

  def update_receipt
    receipt = Receipttaxinvoice.find(params[:id])
    receipt.update_attributes!(
      :date         => params[:date],
      :printdate    => params[:printdate],
      :billing_date => params[:billing_date]
    )

    redirect_to "/reports/unpaid_invoice", notice: "Tanda Terima berhasil di-update!"
  rescue => e
    redirect_back fallback_location: "/reports/unpaid_invoice", alert: e.message
  end

  def destroy
    receipt = Receipttaxinvoice.find(params[:id])
    ActiveRecord::Base.transaction do
      Taxinvoice.where(receipttaxinvoice_id: receipt.id)
                .update_all(receipttaxinvoice_id: nil)
      receipt.update!(
        deleted: true,
        deleteuser_id: current_user.id
      )
    end

    flash[:notice] = 'Data berhasil dihapus'
    redirect_to receipttaxinvoices_path(
      startdate: receipt.created_at.strftime('%d-%m-%Y'),
      enddate:   receipt.created_at.strftime('%d-%m-%Y')
    )
  end

  def print
    @receipt = Receipttaxinvoice.find(params[:id])
  end

  def confirm_billing
    receipt = Receipttaxinvoice.find(params[:id])
    receipt.billing_date = Date.today
    receipt.save

    flash[:notice] = 'Data berhasil dikonfirmasi'
    redirect_to receipttaxinvoices_path(:startdate => receipt.created_at.strftime('%d-%m-%Y'), :enddate => receipt.created_at.strftime('%d-%m-%Y'))
  end

  def update_printdate
    receipt = Receipttaxinvoice.find(params[:id])
    receipt.printdate = Date.today
    receipt.printuser_id = current_user.id
    receipt.save
    render :json => { :success => true,  :printdate => receipt.printdate }.to_json;
  end

  def download_excel
    # mengubah string tanggal menjadi Date aman untuk Ruby 1.9
    begin
      @startdate = params[:startdate].present? ? Date.strptime(params[:startdate], "%d-%m-%Y") : Date.today
    rescue
      @startdate = Date.today
    end

    begin
      @enddate = params[:enddate].present? ? Date.strptime(params[:enddate], "%d-%m-%Y") : Date.today
    rescue
      @enddate = Date.today
    end

    @receipts = Receipttaxinvoice.active.
                  includes(:user, :taxinvoices).
                  where("created_at BETWEEN ? AND ?",
                        @startdate.beginning_of_day,
                        @enddate.end_of_day).
                  order("created_at DESC")

    title = "Tanda Terima Invoice Tagihan #{@startdate.strftime('%d-%m-%Y')}"

    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Tanda Terima") do |sheet|
      # STYLES ==================================================
      bold       = sheet.styles.add_style(:b => true)
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      wrap_txt   = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

      # HEADER CETAK ===========================================
      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"],
                    :style => [nil, bold]

      sheet.add_row [''], :height => 20
      client_name = Setting.find_by_name("Client Name").try(:value).to_s
      sheet.add_row ['', "#{client_name} / Tanda Terima Invoice Tagihan #{@startdate.strftime('%d-%m-%Y')}"],
                    :style => [nil, bold]

      sheet.add_row [''], :height => 20

      # HEADER TABEL ===========================================
      sheet.add_row ['', 'Kode', 'Tgl Buat', 'User', 'Print Oleh', 'Invoice Tagihan'],
                    :style => [nil, bold, bold, bold, bold, bold]

      # ISI DATA ===============================================
      @receipts.each_with_index do |receipt, i|
        invoice_list = receipt.taxinvoices.map { |inv| inv.long_id }.join("\n")

        sheet.add_row [
          '',
          zeropad(receipt.id),
          receipt.created_at.strftime('%d-%m-%y'),
          (receipt.user.try(:username) || "-"),
          (receipt.printuser.try(:username) rescue "-"),
          invoice_list
        ], :style => [nil, nil, nil, nil, nil, wrap_txt]

        # pastikan wrap kolom invoice bekerja
        sheet.rows.last.cells.last.style = wrap_txt
      end

      sheet.add_row ['', '', '', '', '', ''], :height => 15
    end

    p.use_shared_strings = true
    send_data p.to_stream.read,
              :type       => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              :filename   => "#{title}.xlsx",
              :x_sendfile => true
  end

  def download_excel_preview
    # hanya export yang dipilih
    if params[:taxinvoice_ids].present?
      @taxinvoices = Taxinvoice.includes(:customer, :user).where(:id => params[:taxinvoice_ids])

      @totals_by_invoice    = Taxinvoiceitem.group(:taxinvoice_id).sum(:total)
      @generics_by_invoice  = Taxgenericitem.group(:taxinvoice_id).sum(:total)
    else
      redirect_to request.referer, :alert => "Tidak ada invoice yang dipilih"
      return
    end

    title = "Invoice Tagihan (Selected)"

    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Invoice Tagihan") do |sheet|

      # STYLES ======================================
      bold     = sheet.styles.add_style(:b => true)
      center   = sheet.styles.add_style(:alignment => {:horizontal => :center})
      right    = sheet.styles.add_style(:alignment => {:horizontal => :right})
      wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

      # HEADER CETAK ================================
      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"], :style => [nil, bold]
      sheet.add_row [''], :height => 20
      sheet.add_row ['', "#{Setting.find_by_name("Client Name").value} / Invoice Tagihan"], :style => [nil, bold]
      sheet.add_row [''], :height => 20

      # HEADER TABEL ==============================
      sheet.add_row [
        '', 'Pelanggan', 'No Invoice', 'Kirim', 'Konfirm', 'J. Tempo', 'DPP', 'PPN', 'PPH', 'Total'
      ], :style => [nil, bold, bold, bold, bold, bold, bold, bold, bold, bold]

      # DATA ======================================
      @taxinvoices.each do |inv|
        # HITUNG DUE DATE AMAN RUBY 1.9
        last_rev = inv.customernotes.where("revision_date IS NOT NULL AND deleted = false").first

        base_date = if last_rev.present?
          last_rev.revision_date
        else
          inv.sentdate || inv.date
        end

        due_date = base_date + inv.customer.terms_of_payment_in_days.to_i.days

        # TOTAL (downpayment mix)
        net_total = inv.total -
                    (inv.try(:downpayment)     || 0) -
                    (inv.try(:secondpayment)   || 0) -
                    (inv.try(:thirdpayment)    || 0) -
                    (inv.try(:fourthpayment)   || 0)

        # DPP (Generic Items Split)
        if !inv.generic
          dpp = @totals_by_invoice[inv.id] || 0
        else
          dpp = @generics_by_invoice[inv.id] || 0
        end

        sheet.add_row [
          '',
          inv.customer.name,
          inv.long_id,
          (inv.sentdate.strftime('%d-%m-%y') rescue nil),
          (inv.confirmeddate.strftime('%d-%m-%y') rescue nil),
          due_date.strftime('%d-%m-%y'),
          dpp,
          inv.gst_tax,
          inv.price_tax,
          net_total
        ], :style => [nil, nil, wrap_txt, center, center, center, right, right, right, right]
      end

      sheet.add_row ['', '', '', '', '', '', '', '', '', ''], :height => 15
    end

    p.use_shared_strings = true

    send_data p.to_stream.read,
              :filename   => "#{title}.xlsx",
              :type       => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
              :x_sendfile => true
  end

  def preview
    if params[:taxinvoice_ids].blank?
      redirect_to(
        unpaid_invoice_path,
        alert: "Pilih invoice terlebih dahulu"
      ) and return
    end

    ActiveRecord::Base.transaction do
      selected_ids = params[:taxinvoice_ids]
      old_receipt_ids = Taxinvoice.where(id: selected_ids)
                                  .pluck(:receipttaxinvoice_id)
                                  .compact
      old_receipts = Receipttaxinvoice.where(id: old_receipt_ids)

      old_receipts.each do |receipt|
        Taxinvoice.where(receipttaxinvoice_id: receipt.id)
                  .update_all(receipttaxinvoice_id: nil)
        # receipt.update_attributes!(:deleted => true)
      end

      @receipt = Receipttaxinvoice.new(receipt_params)
      @receipt.user_id = current_user.id
      @receipt.printdate = Date.today
      @receipt.taxinvoice_list = params[:taxinvoice_ids].to_json
      @receipt.save!

      Taxinvoice.where(id: selected_ids)
                .update_all(receipttaxinvoice_id: @receipt.id)
    end

    @taxinvoices = Taxinvoice.includes(:customer, :user)
                            .where(id: params[:taxinvoice_ids])

    @totals_by_invoice = Taxinvoiceitem.group(:taxinvoice_id).sum(:total)
    @generics_by_invoice = Taxgenericitem.group(:taxinvoice_id).sum(:total)
  end

  private
  def receipt_params
    {
      :printdate      => params[:printdate],
      :user_id        => params[:user_id],
      :printuser_id   => params[:printuser_id],
      :billing_date   => params[:billing_date]
    }
  end

end
