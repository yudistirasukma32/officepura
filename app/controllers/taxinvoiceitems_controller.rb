class TaxinvoiceitemsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:updateitems, :rejected]
  protect_from_forgery :except => [:updateitems, :rejected]
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions2"
    @where = "taxinvoiceitems"
  end

  def index
    @section = "taxinvoiceitems"
    @where = "taxinvoiceitems"
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

    @invoice_id = params[:invoice_id] || ''
    @plat_type = params[:plat_type] || ''
    @spk_number = params[:spk_number] || ''
    general_where = "invoices.id in (select invoice_id from receipts where deleted = false) and invoices.id not in(select invoice_id from invoicereturns where deleted = false)"
    if !@invoice_id.blank?
      @invoices = Invoice.where('deleted = false and id = ? ', params[:invoice_id]).where(general_where)
      # @invoices = @invoices.where("id not in(?)",bkm_invoice_id.join(",")) if bkm_invoice_id.present?
    elsif !@spk_number.blank?
      @invoices = Invoice.where('deleted = false and spk_number = ?', params[:spk_number]).where(general_where)
    elsif !@plat_type.blank?
      @invoices = Invoice.joins(:vehicle).where('vehicles.plat_type = ?', @plat_type).where('invoices.deleted = false and invoices.date BETWEEN :startdate AND :enddate', {:startdate => @startdate.to_date, :enddate => @enddate.to_date} ).where(general_where)
    else
      @invoices = Invoice.where('date BETWEEN :startdate AND :enddate and deleted = false', {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).where(general_where)
      # @invoices = Invoice.where('date BETWEEN :startdate AND :enddate and deleted = false', {:startdate => @startdate.to_date, :enddate => @enddate.to_date})
    end

    #hide bkk bongkar
    @invoices = @invoices.where('invoice_id is null')
    #hide bkk kosongan
    @cust_kosongan = Customer.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*INTI.*'").pluck(:id)

    @invoices = @invoices.where("customer_id NOT IN (?)", @cust_kosongan).order(:id)

    if params[:customer_id].present?
      @invoices = @invoices.where(customer_id: params[:customer_id])
    end

    if params[:lain].present?
      if params[:lain] == "belum-sj"
        invoice_id = Taxinvoiceitem.joins(:invoice).where(deleted: false).where("invoices.deleted = false and invoices.date between ? and ?", @startdate.to_date, @enddate.to_date).where("taxinvoiceitems.total > money(0)").pluck(:invoice_id)
      elsif params[:lain] == 'belum-invoice'

        invoice_id = Taxinvoiceitem.joins(:invoice).where(deleted: false).where("invoices.deleted = false and invoices.date between ? and ?", @startdate.to_date, @enddate.to_date).where(taxinvoice_id: nil).where("taxinvoiceitems.total > money(0)").pluck(:invoice_id)
        # render json: invoice_id
        # return false
      elsif params[:lain] == 'upload-invoice'
        invoice_id = Invoice.joins(:attachments).where("attachments.file_uid is not null and attachments.file_uid <> '' and invoices.deleted = false and invoices.date between ? and ?", @startdate.to_date, @enddate.to_date).pluck(:id)
      end
    else
      invoice_id = []
    end
    
    if params[:lain] == 'belum-invoice'
      if invoice_id.length > 0
        @invoices = @invoices.where("invoices.id in (#{invoice_id.join(",")})")
      else
        @invoices = Invoice.active.where("id < 0")
      end
    else
      if invoice_id.length > 0
          @invoices = @invoices.where("invoices.id not in (#{invoice_id.join(",")})")
        end
    end

    # bkm_invoice_id = Invoicereturn.joins(:invoice).where(deleted: false).where("invoices.deleted = false and invoices.date between ? and ?", @startdate.to_date, @enddate.to_date).pluck(:invoice_id)
    # @invoices = @invoices.where("id not in(#{bkm_invoice_id.join(",")})") if bkm_invoice_id.present?
    
    # confirmed_invoice_id = Receipt.joins(:invoice).where(deleted: false).where("invoices.deleted = false and invoices.date between ? and ?", @startdate.to_date, @enddate.to_date).pluck(:invoice_id)
    # @invoices = @invoices.where("id in(#{confirmed_invoice_id.join(",")})") if confirmed_invoice_id.present?
    
    if checkroleonly 'Vendor Supir'

      @vendor = Vendor.where('user_id = ?', current_user.id)

      if @vendor.present? 
        @invoices = @invoices.where('driver_id in (select id from drivers where vendor_id = ?)', @vendor[0].id)
      end

    end
    
    @invoices = @invoices.order(:id)
    # render json: confirmed_invoice_id
    # return false
    respond_to :html
  end

  def new
    @section = "taxinvoiceitems"
    @where = "taxinvoiceitems"
    @errors = Hash.new

    @invoice_id = params[:invoice_id] 

    if @invoice_id.blank?
      @errors["invoice"] = "BKK harus diisi."
    else
      @invoice = Invoice.find(@invoice_id) rescue nil

      @taxinvoiceitems = Taxinvoiceitem.where("invoice_id = #{@invoice.id} AND deleted = FALSE") rescue nil
 
      if @invoice.nil?
        @errors["invoice"] = "BKK No. '#{zeropad(@invoice_id)}' tidak terdaftar." 
      end

      if Invoicereturn.where(deleted: false, invoice_id: @invoice.id).count > 0
        redirect_to taxinvoiceitems_url(startdate: (@invoice.date.strftime("%d-%m-%Y") rescue nil), enddate: (@invoice.date.strftime("%d-%m-%Y") rescue nil)), notice: "BKK No. '#{zeropad(@invoice_id)}' sudah di BKM kan." 
        return false
      end
      
      if Receipt.where(deleted: false, invoice_id: @invoice.id).count == 0
        redirect_to taxinvoiceitems_url(startdate: (@invoice.date.strftime("%d-%m-%Y") rescue nil), enddate: (@invoice.date.strftime("%d-%m-%Y") rescue nil)), notice: "BKK No. '#{zeropad(@invoice_id)}' Belum di konfirmasi kasir." 
        return false
      end
    end 

    if @errors.length == 0
      if @invoice.price_per.to_i == 0 
        @invoice.price_per = @invoice.route.price_per if !@invoice.route_id.blank?
        @invoice.save
      end

      if params[:update] == 'true'
        @invoice.price_per = @invoice.route.price_per if !@invoice.route_id.blank? 
        @invoice.save

        if @invoice.taxinvoiceitems.any?
          @invoice.taxinvoiceitems.each do |taxinvoiceitem|
            taxinvoiceitem.price_per = @invoice.price_per
            if taxinvoiceitem.is_wholesale
              taxinvoiceitem.total = taxinvoiceitem.wholesale_price
            elsif taxinvoiceitem.is_gross
              taxinvoiceitem.total = taxinvoiceitem.weight_gross.to_i * taxinvoiceitem.price_per.to_f
            else
              taxinvoiceitem.total = taxinvoiceitem.weight_net.to_i * taxinvoiceitem.price_per.to_f   
            end

            taxinvoiceitem.save
          end
        end
      end

      if !@invoice.taxinvoiceitems.any?
        qty = @invoice.quantity
        
        if @invoice.receiptreturns.active.any?
          qty -= @invoice.receiptreturns.active.sum(:quantity)
        end

        1.upto(qty) do |i|
          @taxinvoiceitem = Taxinvoiceitem.new
          @invoice.taxinvoiceitems << @taxinvoiceitem
        end
      else
           #check if invoiceitems.count = (invoice.quantity - invoice.invoicereturns.quantity), if less then add 
          @invoiceitemsnull = @invoice.taxinvoiceitems.where("sku_id IS null")
          @invoiceitemsnull.each do |invoiceitemsnull|
            invoiceitemsnull.destroy
          end
          
          c = @invoice.taxinvoiceitems.where("sku_id IS NOT null").count 

          qty = @invoice.quantity
          if @invoice.receiptreturns.active.any?
            qty -= @invoice.receiptreturns.active.sum(:quantity) 
          end
              
          if c < qty   
            c.upto(qty-1) do |i|
              @taxinvoiceitem = Taxinvoiceitem.new
              @invoice.taxinvoiceitems << @taxinvoiceitem 
            end
          end 

          @is_wholesale = @invoice.taxinvoiceitems.where(:is_wholesale => true).any?       
      end    
    end  
  end

  def updateitems
    inputs = params["taxinvoiceitems"]

    @invoice = Invoice.find(inputs[:invoice_id])
    
    if @invoice.taxinvoiceitems.any?
      @invoice.taxinvoiceitems.each do |item|
        item_id = item.id.to_s
        if inputs["total_" + item_id] != "0" and item.taxinvoice_id.nil?
          item.date = inputs["date_" + item_id]
          item.sku_id = inputs["sku_id_" + item_id]
          item.weight_gross = inputs["weight_gross_" + item_id].blank? ? 0 : inputs["weight_gross_" + item_id]
          item.load_date = inputs["load_date_" + item_id]
          item.weight_net = inputs["weight_net_" + item_id].blank? ? 0 : inputs["weight_net_" + item_id]
          item.unload_date = inputs["unload_date_" + item_id]
          item.price_per = @invoice.price_per.to_f
          item.total = item.price_per.to_f >= 300000 ? item.price_per.to_f : item.price_per.to_f * item.weight_net
          item.office_id = @invoice.office_id
          item.customer_id = @invoice.customer_id
          item.wholesale_price = inputs["wholesale_price"].to_f
          item.user_id = current_user.id
          item.save
        end
      end
      redirect_to("/taxinvoiceitems/new/" + @invoice.id.to_s, :notice => 'Data Surat Tagihan sukses di simpan.')
    else
      redirect_to("/taxinvoiceitems/new/" + @invoice.id.to_s)      
    end    
  end

  def getCustomerbyDate
    date = params[:date]

    #customer = Customer.where("id in (select customer_id from invoices where date = ? ) and id in (Select customer_id from taxinvoiceitems where total > '$0.00')", date.to_date).order(:name)
    customer = Customer.where("id in (select customer_id from invoices where date = ? and deleted = false)", date.to_date).order(:name)
    render :json => {:success => true, :layout => false,
      :customer => customer
      }.to_json;

  end

  # Excel
  def downloadexcel
    invoice_id = params[:id]
    invoice = Invoice.find(invoice_id)
    index_col = 1
    excel = Axlsx::Package.new
    excel.workbook.add_worksheet(:name => "Tagihan Invoice") do |sheet|
  
    bold = sheet.styles.add_style(:b => true)
    right = sheet.styles.add_style(:alignment => {:horizontal => :right})
    right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
    
    index_col +1
    sheet.add_row ['Kantor '+invoice.office.name], :height => 20
    index_col +=1
    sheet.add_row [''], :height => 20
    index_col +=1
    sheet.add_row ['No. Invoice', invoice.id], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    sheet.add_row ['Tgl Bikin', invoice.created_at.strftime('%d-%m-%Y')], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    sheet.add_row ['Nama Pelanggan', invoice.customer.name], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    sheet.add_row ['Jurusan', "#{invoice.quantity} Rit: #{invoice.route.name}, #{invoice.vehicle.current_id}"], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    if invoice.price_per.to_f != invoice.route.price_per.to_f
    sheet.add_row ['Harga Lama', to_currency_bank(invoice.price_per, 'Rp. ')], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    sheet.add_row ['Harga Baru', to_currency_bank(invoice.route.price_per, 'Rp. ')], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    else
    sheet.add_row ['Harga Muatan', "@ "+to_currency_bank(invoice.price_per, 'Rp. ')+" *"], :height => 20, :widths => [:auto, :auto, :auto]
    index_col +=1
    end
    sheet.add_row [''], :height => 20
    index_col +=1
    sheet.add_row ['No','Tanggal','Surat Jalan','Tgl Muat','Muat','Tgl Bongkar','Bongkar','Susut'], :height => 20, :widths => [:auto]
  
    invoice.taxinvoiceitems.each_with_index do |item, i|
      sheet.add_row [i+1,item.date.strftime("%d-%m-%Y"),item.sku_id,item.load_date.strftime("%d-%m-%Y"),'Muat',item.unload_date.strftime("%d-%m-%Y"),item.weight_gross,item.weight_net],:height => 20, :widths => [:auto]
    end
  
  
    end
    excel.use_autowidth = false
    excel.use_shared_strings = true
    
    #if p.serialize("/tmp/#{filename}")
      #send_data("#{Rails.root}/tmp/#{filename}", :filename => filename, :type => :xls, :x_sendfile => true)
    #end
  
    send_data(excel.to_stream.read, :filename => "Surat Jalan no #{invoice.id}.xls", :type => :xls, :x_sendfile => true)
      
  
  end
  
  #for printOnly
  def print
    
    @errors = Hash.new

    @invoice_id = params[:invoice_id] 

    if @invoice_id.blank?
      @errors["invoice"] = "BKK harus diisi."
    else
      @invoice = Invoice.find(@invoice_id) rescue nil
      if @invoice.nil?
        @errors["invoice"] = "BKK No. '#{zeropad(@invoice_id)}' tidak terdaftar." 
      end
    end 

    if @errors.length == 0
      if @invoice.price_per.to_i == 0 
        @invoice.price_per = @invoice.route.price_per if !@invoice.route_id.blank?
        @invoice.save
      end

      if params[:update] == 'true'
        @invoice.price_per = @invoice.route.price_per if !@invoice.route_id.blank? 
        @invoice.save

        if @invoice.taxinvoiceitems.any?
          @invoice.taxinvoiceitems.each do |taxinvoiceitem|
            taxinvoiceitem.price_per = @invoice.price_per
            if taxinvoiceitem.is_wholesale
              taxinvoiceitem.total = taxinvoiceitem.wholesale_price
            elsif taxinvoiceitem.is_gross
              taxinvoiceitem.total = taxinvoiceitem.weight_gross.to_i * taxinvoiceitem.price_per.to_f
            else
              taxinvoiceitem.total = taxinvoiceitem.weight_net.to_i * taxinvoiceitem.price_per.to_f   
            end

            taxinvoiceitem.save
          end
        end
      end

      if !@invoice.taxinvoiceitems.any?
        qty = @invoice.quantity
        
        if !@invoice.receiptreturns.active.first.nil?
          qty -= @invoice.receiptreturns.active.first.quantity 
        end

        1.upto(qty) do |i|
          @taxinvoiceitem = Taxinvoiceitem.new
          @invoice.taxinvoiceitems << @taxinvoiceitem
        end
      else
            #check if invoiceitems.count = (invoice.quantity - invoice.invoicereturns.quantity), if less then add 
          @invoiceitemsnull = @invoice.taxinvoiceitems.where("sku_id IS null")
          @invoiceitemsnull.each do |invoiceitemsnull|
            invoiceitemsnull.destroy
          end
          
          c = @invoice.taxinvoiceitems.where("sku_id IS NOT null").count 

          qty = @invoice.quantity
          if !@invoice.receiptreturns.active.first.nil?
            qty -= @invoice.receiptreturns.active.first.quantity 
          end
              
          if c < qty   
            c.upto(qty-1) do |i|
              @taxinvoiceitem = Taxinvoiceitem.new
              @invoice.taxinvoiceitems << @taxinvoiceitem 
            end
          end 

          @is_wholesale = @invoice.taxinvoiceitems.where(:is_wholesale => true).any?       
      end    
    end  
  end

  def create
  end

  def update
  end

  def destroy
    Taxinvoiceitem.destroy(params[:id])
    redirect_to request.referer
  end
  
  def rejected
    inputs = params[:taxinvoiceitems]
    # render json: inputs
    @taxinvoiceitem = Taxinvoiceitem.find(params[:id])
    @taxinvoiceitem.rejected = inputs[:rejected]
    @taxinvoiceitem.reject_reason = inputs[:reject_reason] 

    if @taxinvoiceitem.save
      redirect_to("/taxinvoiceitems/new/" + @taxinvoiceitem.invoice_id.to_s, :notice => 'Data Surat Tagihan sukses diupdate.')
    end

  end
  
  #testing

  def index2
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

    @invoice_id = params[:invoice_id] || ''
    @plat_type = params[:plat_type] || ''
    @spk_number = params[:spk_number] || ''

    if !@invoice_id.blank?
      @invoices = Invoice.where('deleted = false and id = ?', params[:invoice_id]).order(:id)
    elsif !@spk_number.blank?
      @invoices = Invoice.where('deleted = false and spk_number = ?', params[:spk_number]).order(:id)
    elsif !@plat_type.blank?
      @invoices = Invoice.joins(:vehicle).where('vehicles.plat_type = ?', @plat_type).where('invoices.deleted = false and invoices.date BETWEEN :startdate AND :enddate and invoices.id in (select invoice_id from receipts where deleted = false)', {:startdate => @startdate.to_date, :enddate => @enddate.to_date} )
    else
      @invoices = Invoice.where('date BETWEEN :startdate AND :enddate and deleted = false and id in (select invoice_id from receipts where deleted = false)', {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id)
    end

    respond_to :html
  end

end
