class ReceiptreturnsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "cashiers"
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @receipts = Receiptreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    respond_to :html
  end

  def new
    @receipt = Receiptreturn.new
    @invoice = Invoicereturn.where(:id => params[:invoicereturn_id], :deleted => false).first rescue nil
  end

  def create
    @errors = Hash.new
    @receipt = Receiptreturn.new

    inputs = params[:receiptreturn]
    @invoice = Invoicereturn.find(inputs[:invoicereturn_id]) rescue nil
   
    if inputs[:action] == 'create'    
      @receipt.invoice_id = inputs[:invoice_id]
      @receipt.invoicereturn_id = inputs[:invoicereturn_id]
      @receipt.office_id = @invoice.office_id
      @receipt.quantity = @invoice.quantity
      @receipt.ferry_fee = @invoice.ferry_fee.to_i
      @receipt.tol_fee = @invoice.tol_fee.to_i
      @receipt.driver_allowance = @invoice.driver_allowance.to_i
      @receipt.helper_allowance = @invoice.helper_allowance.to_i
      @receipt.misc_allowance = @invoice.misc_allowance.to_i
      @receipt.premi_allowance = @invoice.premi_allowance.to_i
      @receipt.gas_allowance = 0
      @receipt.total = @receipt.driver_allowance + @receipt.tol_fee + @receipt.ferry_fee + @receipt.misc_allowance + @receipt.helper_allowance + @receipt.premi_allowance
      @receipt.user_id = current_user.id

      
      if ([99].include? @invoice.office_id)

        @receipt.driver_allowance = 0
        @receipt.helper_allowance = 0
        @receipt.misc_allowance = 0
        @receipt.ferry_fee = 0
        @receipt.tol_fee = 0
        @receipt.gas_allowance = 0
        @receipt.total = 0

      end
      
      receipt_exist = Receiptreturn.where(:invoice_id => @receipt.invoice_id, :invoiceturn_id => @receipt.invoicereturn_id, :deleted => false).first rescue nil
      if receipt_exist.nil?
        @receipt.save

        updateofficecash @receipt.total
        redirect_to(cashiers_path, :notice => 'BKK No. ' + zeropad(inputs[:invoice_id]) + ' sukses di tambah.')
      else
        redirect_to(cashiers_url)
      end
      
    else
      @invoice_id = inputs[:invoice_id]
      render :action => "new"
    end
  end

  def edit
    @errors = Hash.new
    @receipt = Receiptreturn.find(params[:id]) rescue nil
  end

  def update
    @errors = Hash.new
    inputs = params[:receiptreturn]
    @receipt = Receiptreturn.find(inputs[:receipt_id]) rescue nil

    past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
    if past_date != inputs[:created_at]
      updatecashdailylog @receipt.total * -1, past_date

      datestring = inputs[:created_at].split('-')
      present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
      updatecashdailylog @receipt.total, present_date.strftime('%d-%m-%Y')

      @receipt.created_at = present_date
      @receipt.save
      redirect_to(cashiers_path, :notice => 'Kasir BKM No. ' + zeropad(inputs[:receipt_id]) + ' sukses di tambah.')
    else
      redirect_to(cashiers_path)
    end
  end

  def destroy
    @receipt = Receiptreturn.find(params[:id])
    
    updateofficecash @receipt.total * -1, @receipt.created_at.strftime('%d-%m-%Y')   
    @receipt.deleted = true
    @receipt.deleteuser_id = current_user.id
    @receipt.save
    redirect_to(cashiers_path)
  end  

end
