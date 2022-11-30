class ReceiptshipsController < ApplicationController
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
    @receiptships = Receiptship.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    @dateshow = Date.today.strftime('%b %Y')
    respond_to :html
  end

  def new
    @receiptship = Receiptship.new
    @errors = Hash.new
    @shipexpense_id = params[:shipexpense_id]
    @shipexpense = Shipexpense.find(params[:shipexpense_id]) rescue nil
  end

  def create
    @receiptship = Receiptship.new
    @errors = Hash.new
    inputs = params[:receiptship]
    @shipexpense = Shipexpense.find(inputs[:shipexpense_id]) rescue nil

      if checkavailableofficecash(@shipexpense.total) == true
        @receiptship.shipexpense_id = inputs[:shipexpense_id]
        @receiptship.office_id = @shipexpense.invoice.office_id
        @receiptship.misc_total = @shipexpense.misc_total.to_i
        @receiptship.total = @shipexpense.total.to_i
        @receiptship.gst_tax = @shipexpense.gst_tax.to_f
        @receiptship.gst_percentage = @shipexpense.gst_percentage.to_i
        @receiptship.user_id = current_user.id
        @receiptship.expensetype = @shipexpense.expensetype

        receipt_exist = Receiptship.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil
        if receipt_exist.nil?
          @receiptship.transaction do
            if @receiptship.save
              updateofficecash @receiptship.total * -1
              redirect_to(cashiers_path(:date => @shipexpense.date.strftime('%d-%m-%Y')), :notice => 'Biaya Kapal No. ' + zeropad(inputs[:shipexpense_id]) + ' sukses ditambah.')
            end
          end
        end

      else
        @shipexpense_id = inputs[:shipexpense_id]
        @errors["receiptship"] = 'Biaya Kapal No. ' + zeropad(inputs[:shipexpense_id]) + ' gagal ditambah, uang kas tidak memenuhi'
        render :action => "new", :notice => 'Biaya Kapal No. ' + zeropad(inputs[:shipexpense_id]) + ' gagal ditambah, uang kas tidak memenuhi'
      end

  end

  def edit
    @errors = Hash.new
    @receiptship = Receiptship.find(params[:id]) rescue nil
  end

  def update
    @errors = Hash.new
    inputs = params[:receipt]
    @receiptship = Receiptship.find(inputs[:receipt_id]) rescue nil

    past_date = @receiptship.created_at.to_date.strftime('%d-%m-%Y')
    if past_date != inputs[:created_at]
      updatecashdailylog @receiptship.total, past_date

      datestring = inputs[:created_at].split('-')
      present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
      updatecashdailylog @receiptship.total * -1, present_date.strftime('%d-%m-%Y')

      @receiptship.created_at = present_date
      @receiptship.save
      redirect_to(cashiers_path(:date => @receiptship.created_at.strftime('%d-%m-%Y')), :notice => 'Kasir BKK No. ' + zeropad(inputs[:receipt_id]) + ' sukses di tambah.')
    else
      redirect_to(cashiers_path(:date => @receiptship.created_at.strftime('%d-%m-%Y')))
    end
  end

 def destroy
    @receiptship = Receiptship.find(params[:id])
     
    @receiptship.deleted = true
    @receiptship.deleteuser_id = current_user.id

    @receiptship.transaction do
      @receiptship.save
      updateofficecash @receiptship.total, @receiptship.created_at.strftime('%d-%m-%Y') 
    end
    
    redirect_to(cashiers_path(:date => @receiptship.created_at.strftime('%d-%m-%Y')))
  end  

end
