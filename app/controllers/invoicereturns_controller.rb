class InvoicereturnsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section, :set_role

  $globalDate = Date.today.strftime('%d-%m-%Y')

  def set_section
    @section = "transactions"
    @where = "invoicereturns"
  end

  def set_role
    @user_role = "Admin Operasional, Staff Operasional, Admin BKM"
  end

  def index
    role = cek_roles @user_role
    if role
      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      $globalDate = @date
      @invoices = Invoice.where('date = ? AND deleted = false AND id NOT IN (SELECT invoice_id FROM taxinvoiceitems WHERE deleted = false AND money(total) > money(0)) AND id IN (SELECT invoice_id FROM receipts WHERE deleted = false)', @date.to_date).order(:id) 
      @invoicereturns = Invoicereturn.where('invoice_id in (select id from invoices where date = ?) AND deleted = false', @date.to_date)
      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def index_confirmed
    role = cek_roles @user_role
    if role
      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      $globalDate = @date
      @invoices = Invoice.where('date = ? AND deleted = false', @date.to_date).order(:id) 
      @invoicereturns = Invoicereturn.where('date = ?', @date.to_date)
      respond_to :html
     else
      redirect_to root_path()
    end
  end

  def new
    role = cek_roles @user_role
    if role
      @invoicereturn = Invoicereturn.new
      @invoice = Invoice.where(:id =>params[:invoice_id], :deleted => false).first rescue nil
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      @invoice_id = @invoice.id
      @errors = Hash.new
     else
      redirect_to root_path()
    end
  end

  def create
    @errors = Hash.new
    @invoicereturn = Invoicereturn.new
    
    inputs = params[:invoicereturn]
    @invoice = Invoice.where(:id =>inputs[:invoice_id], :deleted => false).first rescue nil
    @invoicereturn.date = Date.today.strftime('%d-%m-%Y')

    if inputs[:process] == "create"

      if inputs[:quantity].to_i > @invoice.quantity
        @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
        @invoicereturns = Invoicereturn.where('extract(year from date) = ? AND extract(month from date) = ? AND extract(day from date) = ?', Date.today.year, Date.today.month, Date.today.day).order('date DESC')
        @dateshow = Date.today.strftime('%d %b %Y') + ' (Hari ini)'
        @invoice_id = inputs[:invoice_id]
        flash[:notice] = 'Jumlah rit tidak boleh melebihi max ' + @invoice.quantity.to_s
        render :action => "new"
      else
        @invoicereturn.date = inputs[:date]
        @invoicereturn.invoice_id = inputs[:invoice_id]
        @invoicereturn.quantity = inputs[:quantity]          
        @invoicereturn.gas_leftover = inputs[:gas_leftover]
        gas_leftover_cash = @invoicereturn.gas_leftover * @invoice.gas_cost
        @invoicereturn.ferry_fee = inputs[:ferry_fee].to_i
        @invoicereturn.tol_fee = inputs[:tol_fee].to_i
        @invoicereturn.driver_allowance = inputs[:driver_allowance].to_i
        @invoicereturn.helper_allowance = inputs[:helper_allowance].to_i
        @invoicereturn.misc_allowance = inputs[:misc_allowance].to_i
        @invoicereturn.premi_allowance = inputs[:premi_allowance].to_i
        @invoicereturn.gas_allowance = (@invoice.gas_allowance.to_i / @invoice.quantity) * @invoicereturn.quantity
        @invoicereturn.total = @invoicereturn.driver_allowance.to_i + @invoicereturn.helper_allowance.to_i + @invoicereturn.misc_allowance.to_i + @invoicereturn.tol_fee.to_i + @invoicereturn.ferry_fee.to_i + @invoicereturn.premi_allowance.to_i + @invoicereturn.gas_allowance - gas_leftover_cash
        @invoicereturn.office_id = @invoice.office_id
        @invoicereturn.user_id = current_user.id
        
        #update vehicle gas
        vehicle = @invoice.vehicle
        vehicle.gas_leftover = (vehicle.gas_leftover || 0) + inputs[:gas_leftover].to_i
        vehicle.save

        #update invoicetrain
        if @invoicereturn.invoice.invoicetrain
            inv = @invoicereturn.invoice
            inv.invoice_id = nil
            inv.save
        end
        
        @invoicereturn.save
        redirect_to(invoicereturns_path, :notice => 'BKK No. ' + zeropad(inputs[:invoice_id]) + ' sukses di tambah.')
      end
    else
      @invoice_id = inputs[:invoice_id]
      render :action => "new"
    end
  end

  def update
  end

  def add
    @invoicereturn = Invoicereturn.new
    @invoice = Invoice.where(:id => params[:invoice_id], :deleted => false).first rescue nil
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    $globalDate = @date
    @invoice_id = @invoice.id if !@invoice.nil?
    @errors = Hash.new
    @where = "invoicereturnadd"
  end

  def destroy
    @invoicereturn = Invoicereturn.find(params[:id])
    
    if @invoicereturn.invoice.receiptreturns.where(:deleted => false).any?
      redirect_to(invoicereturns_url, :notice => 'BKM No. #' + zeropad(@invoicereturn.invoice.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
       #update vehicle gas
      vehicle = @invoicereturn.invoice.vehicle
      vehicle.gas_leftover = vehicle.gas_leftover - @invoicereturn.gas_leftover
      vehicle.save

      @invoicereturn.deleteuser_id = current_user.id
      @invoicereturn.deleted = true
      @invoicereturn.save
      redirect_to(request.referer)
    end
  end  

end
