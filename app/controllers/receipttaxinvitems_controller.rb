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
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
    @receipts = Receipttaxinvitem.active.where("created_at BETWEEN ? AND ?", @startdate.to_datetime, @enddate.to_datetime.end_of_day).order("created_at desc")
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
    receipt.billingdate = params[:billingdate] if params[:billingdate].present?

    if receipt.save
      render json: { status: 200, message: "Data berhasil disimpan.".html_safe }, status: 200
    else
      render json: { status: 400, message: "Data gagal diupdate" }, status: 400
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

  def confirm_billing
    receipt = Receipttaxinvitem.find(params[:id])
    receipt.billingdate = Date.today
    receipt.save

    flash[:notice] = 'Data berhasil dikonfirmasi'
    redirect_to receipttaxinvitems_path(:startdate => receipt.created_at.strftime('%d-%m-%Y'), :enddate => receipt.created_at.strftime('%d-%m-%Y'))
  end

  def update_printdate
    receipt = Receipttaxinvitem.find(params[:id])
    receipt.printdate = Date.today
    receipt.printuser_id = current_user.id
    receipt.save
    render :json => { :success => true,  :printdate => receipt.printdate }.to_json;
  end

    def detail_excel
	
    @receipt = Receipttaxinvitem.find(params[:id])

    # @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    # @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
    # @receipts = Receipttaxinvitem.active.where("created_at BETWEEN ? AND ?", @startdate.to_datetime, @enddate.to_datetime.end_of_day).order("created_at desc")

    # @date = @startdate
		# render json: @receiptexpenses
		# return false

		title = "Tanda Terima Surat Jalan"
	
		green = Axlsx::Color.new :rgb => "FF00FF00"
		red = Axlsx::Color.new :rgb => "FFCC0033"
		p = Axlsx::Package.new

		p.workbook.add_worksheet(name: "Tanda Terima Surat Jalan") do |sheet|
		  bold = sheet.styles.add_style(:b => true)
		  right = sheet.styles.add_style(:alignment => {:horizontal => :right})
		  right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
		  h1 = sheet.styles.add_style :b => true, :sz => 16
		  h2 = sheet.styles.add_style :b => true, :sz => 14
		  h3_green = sheet.styles.add_style :color => green, :b => true
		  h3_red = sheet.styles.add_style :color => red, :b => true
		  number = sheet.styles.add_style :format_code => "#,##0.00"
		  number_green = sheet.styles.add_style :format_code => "#,##0.00", :color => green, :b => true
		  number_red = sheet.styles.add_style :format_code => "#,##0.00", :color => red, :b => true
		  wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})
	
		  sheet.merge_cells "B2:M2"
		  sheet.merge_cells "B4:M4"
		  sheet.add_row [''], :height => 20
		  sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"], :height => 20, :style => [nil, bold]
	
		  sheet.add_row [''], :height => 20
		  sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Tanda Terima Surat Jalan"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]
	
		  sheet.add_row [''], :height => 20
		  sheet.add_row ['No', 'Tgl', 'DO', 'Keterangan', 'Nopol', 'Pelanggan', 'No SJ', 'Tgl Muat', 'Tgl Bongkar', 'Muat', 'Bongkar', 'SJ','INV','UPLD', 'User'],
              :height => 20,
              :style => [bold, bold, bold, bold, bold, bold, bold, bold, bold, bold, bold, bold, bold, bold, bold],
              :widths => [5, :auto, :auto, :auto, :auto, :auto, :auto,:auto, :auto, :auto,:auto, :auto, :auto,:auto, :auto]
		  # render json: sheet.rows.last.index
		  # return false
	
		  # @receipts.each_with_index do |receipt, i|
      @receipt.taxinvoiceitems.order(:date, :sku_id).includes(:invoice, :user).each_with_index do |taxinvoiceitem, i|

      invoice = taxinvoiceitem.invoice
      second_driver = invoice.invoices.active.first.driver.name rescue nil
			description = "##{taxinvoiceitem.invoice_id}: #{taxinvoiceitem.invoice.date.strftime('%d-%m-%Y') rescue nil}, #{taxinvoiceitem.invoice.quantity} Rit: #{taxinvoiceitem.invoice.route.name rescue nil} (#{taxinvoiceitem.invoice.driver.name rescue nil} #{zeropad(invoice.driver.id) rescue nil}) #{taxinvoiceitem.invoice.invoicetrain ? '= Kereta =' : '' rescue nil}
						   #{if taxinvoiceitem.invoice.isotank_id.present? && taxinvoiceitem.invoice.isotank_id.to_i != 0
							  if taxinvoiceitem.invoice.multicontainer
								"Isotank Combo = #{taxinvoiceitem.invoice.isotank.isotanknumber rescue nil} #{taxinvoiceitem.invoice.second_isotank.isotanknumber rescue nil}".html_safe rescue nil
							  else
								"Isotank = #{taxinvoiceitem.invoice.isotank.isotanknumber rescue nil}" rescue nil
							  end
							else
							  ''
							end rescue nil}
		  
						   #{if taxinvoiceitem.invoice.container_id.present? && taxinvoiceitem.invoice.container_id.to_i != 0
							  if taxinvoiceitem.invoice.multicontainer
								"Kontainer Combo = #{taxinvoiceitem.invoice.container.containernumber rescue nil} #{taxinvoiceitem.invoice.second_container.containernumber rescue nil}".html_safe rescue nil
							  else
								"Kontainer = #{taxinvoiceitem.invoice.container.containernumber rescue nil}" rescue nil
							  end
							else
							  ''
							end rescue nil}".squish
      

      if invoice.vehicle_duplicate.present? && invoice.vehicle_duplicate_id != 0 
          vehicle = invoice.vehicle_duplicate.current_id rescue nil 
      else
          vehicle = invoice.vehicle.current_id rescue nil 
      end

			sheet.add_row [
      i+1, 
      (taxinvoiceitem.date.strftime('%d/%m/%y') rescue nil), 
      (invoice.event_id rescue nil), 
      description,
      vehicle,
      (taxinvoiceitem.customer.name rescue nil),
      (taxinvoiceitem.sku_id rescue nil),
      (taxinvoiceitem.load_date.strftime('%d/%m/%y') rescue nil),
      (taxinvoiceitem.unload_date.strftime('%d/%m/%y') rescue nil),
      (taxinvoiceitem.weight_gross rescue 0),
      (taxinvoiceitem.weight_net rescue 0),
      '1 / 1',
      taxinvoiceitem.invoice_id.present? ? '1 / 1' : '0 / 1',
      '1 / 1',
      (taxinvoiceitem.user.username rescue nil),
      ],
			:height => 20,
			:style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]

		  end
	
		  # Grand Total
		  sheet.add_row ['','', '', '', '', '', '','', '', '','', '', '','', '',] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,]
		end

		p.use_autowidth = false
		p.use_shared_strings = true
		send_data p.to_stream.read, type: :xls, filename: "#{title}.xlsx", x_sendfile: true
	end
  
end
