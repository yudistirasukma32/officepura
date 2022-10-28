class BonusreceiptsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  protect_from_forgery :except => [:new, :index, :updateitems]
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "bonusreceipts"
  end

  def index
    @startdate = params[:startdate] || Date.today.at_beginning_of_month.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
    @invoices = Invoice.where("deleted = false AND date BETWEEN :startdate AND :enddate AND route_id in (SELECT id FROM routes where money(bonus) > money(0)) and id not in (SELECT invoice_id FROM bonusreceipts where deleted=false)", {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id)
    respond_to :html
  end

  def index_confirmed
    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
    @bonusreceipts = Bonusreceipt.where("created_at >= ? and created_at < ?", @startdate.to_date, @enddate.to_date + 1.day).order(:id)
    respond_to :html
  end

  def confirmation
    @receipt = Bonusreceipt.find(params[:id])
    respond_to :html
  end

  def new
    @receipt = Bonusreceipt.new
    @receipt_new = true

    @errors = Hash.new
    @invoice_id = params[:invoice_id] 
    @invoice = Invoice.find(@invoice_id) rescue nil
    receipt_exist = Bonusreceipt.where(:invoice_id => params[:invoice_id], :deleted => false).first rescue nil  
    if receipt_exist
      @receipt = receipt_exist
      @receipt_new  = false
    end
      
    if !@invoice.taxinvoiceitems.any?
      qty = @invoice.quantity        
      qty -= @invoice.receiptreturns.where(:deleted => false).sum(:quantity) if @invoice.receiptreturns.where(:deleted => false).any?

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
        if !@invoice.invoicereturns.first.nil?      
          qty -= @invoice.invoicereturns.first.quantity 
        end 
            
        if c < qty   
          c.upto(qty-1) do |i|
            @taxinvoiceitem = Taxinvoiceitem.new
            @invoice.taxinvoiceitems << @taxinvoiceitem 
          end
        end  
             
    end    
    
  end

  def updateitems
    
    @receipt_new = false

    inputs = params[:bonusreceipts]
    @invoice_id = inputs[:invoice_id] 
    @invoice = Invoice.find(@invoice_id) rescue nil
    
    receipt_exist = Bonusreceipt.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil  
    if receipt_exist.nil? 
      @receipt = Bonusreceipt.new
      @receipt_new  = true
    else
      @receipt = receipt_exist
      @receipt_new  = false
    end

    if inputs[:process] == 'create'

      @receipt.invoice_id = inputs[:invoice_id]
      @receipt.office_id = @invoice.office_id
      @receipt.quantity = inputs[:quantity]
      @receipt.total = inputs[:totalbonus] || 0
      @receipt.description =  inputs[:description]
      @receipt.load_location =  inputs[:load_location]
      @receipt.load_date =  inputs[:load_date]
      @receipt.load_hour =  inputs[:load_hour]
      @receipt.unload_location =  inputs[:unload_location]
      @receipt.unload_date =  inputs[:unload_date]
      @receipt.unload_hour =  inputs[:unload_hour]
      @receipt.user_id = current_user.id
      
      if @receipt.save
        if params[:receipt_new]
          @invoice.driver.enabled = true
          @invoice.driver.save

          @driverlogs = Driverlog.new
          @driverlogs.driver_id = @invoice.driver_id
          @driverlogs.ready = true
          @driverlogs.save

          @invoice.vehicle.enabled = true
          @invoice.vehicle.save

          @vehiclelogs = Vehiclelog.new
          @vehiclelogs.vehicle_id = @invoice.vehicle_id
          @vehiclelogs.ready = true
          @vehiclelogs.save
        end
      end
     
      if @invoice.taxinvoiceitems.any?
        @invoice.taxinvoiceitems.each do |item|
          item_id = item.id.to_s
          if !inputs["b_sku_id_" + item_id].blank?
            item.date = inputs["b_date_" + item_id]
            item.sku_id = inputs["b_sku_id_" + item_id]
            item.office_id = @invoice.office_id
            item.customer_id = @invoice.customer_id
            item.price_per = @invoice.price_per
            item.save
          end
        end
        redirect_to(confirmation_bonusreceipt_url(@receipt), :notice => 'Data Surat Jalan sukses di simpan.')
      else
        redirect_to(confirmation_bonusreceipt_url(@receipt))      
      end    
    else
      @invoice_id = inputs[:invoice_id]
      render :action => "new"
    end
  end

 

  def destroy
    @receipt = Bonusreceipt.find(params[:id])
   
    if @receipt.receiptpremis.where(:deleted => false).any?
      redirect_to(bonusreceipts_url, :notice => 'Premi BKK No. #' + zeropad(@receipt.invoice.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
      @receipt.deleteuser_id = current_user.id
      @receipt.deleted = true
      @receipt.save
      redirect_to(bonusreceipts_url)
    end
  end  

end
