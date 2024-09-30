class ReceiptinsurancesController < ApplicationController
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
    @receiptinsurances = Receiptinsurance.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    @dateshow = Date.today.strftime('%b %Y')
    respond_to :html
  end

  def new
    @receiptinsurance = Receiptinsurance.new
    @errors = Hash.new
    @insuranceexpense_id = params[:insuranceexpense_id]
    @insuranceexpense =Insuranceexpense.find(params[:insuranceexpense_id]) rescue nil
  end

  def create
    @receiptinsurance = Receiptinsurance.new
    @errors = Hash.new
    inputs = params[:receiptinsurance]
    @insuranceexpense = Insuranceexpense.find(inputs[:insuranceexpense_id]) rescue nil

 
      if checkavailableofficecash(@insuranceexpense.total.to_i) == true
        @receiptinsurance.insuranceexpense_id = inputs[:insuranceexpense_id]
        @receiptinsurance.tsi_total = inputs[:tsi_total] 
        @receiptinsurance.insurance_rate = inputs[:insurance_rate]
        @receiptinsurance.total = inputs[:total]
        @receiptinsurance.user_id = current_user.id
        @receiptinsurance.expensetype = @insuranceexpense.expensetype

        receipt_exist = Receiptinsurance.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil
        if receipt_exist.nil?
          @receiptinsurance.transaction do
            if @receiptinsurance.save
              updateofficecash @receiptinsurance.total * -1
              redirect_to(cashiers_path(:date => @insuranceexpense.date.strftime('%d-%m-%Y')), :notice => 'Biaya Kapal No. ' + zeropad(inputs[:insuranceexpense_id]) + ' sukses ditambah.')
            end
          end
        end

      else
        @insuranceexpense_id = inputs[:insuranceexpense_id]
        @errors["receiptinsurance"] = 'Biaya Asuransi No. ' + zeropad(inputs[:insuranceexpense_id]) + ' gagal ditambah, uang kas tidak memenuhi'
        render :action => "new", :notice => 'Biaya Asuransi No. ' + zeropad(inputs[:insuranceexpense_id]) + ' gagal ditambah, uang kas tidak memenuhi'
      end

  end

  def edit
    @errors = Hash.new
    @receiptinsurance = Receiptinsurance.find(params[:id]) rescue nil
  end

  def update
    @errors = Hash.new
    inputs = params[:receipt]
    @receiptinsurance = Receiptinsurance.find(inputs[:receipt_id]) rescue nil

    past_date = @receiptinsurance.created_at.to_date.strftime('%d-%m-%Y')
    if past_date != inputs[:created_at]
      updatecashdailylog @receiptinsurance.total, past_date

      datestring = inputs[:created_at].split('-')
      present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
      updatecashdailylog @receiptinsurance.total * -1, present_date.strftime('%d-%m-%Y')

      @receiptinsurance.created_at = present_date
      @receiptinsurance.save
      redirect_to(cashiers_path(:date => @receiptinsurance.created_at.strftime('%d-%m-%Y')), :notice => 'Kasir BKK No. ' + zeropad(inputs[:receipt_id]) + ' sukses di tambah.')
    else
      redirect_to(cashiers_path(:date => @receiptinsurance.created_at.strftime('%d-%m-%Y')))
    end
  end

 def destroy
    @receiptinsurance = Receiptinsurance.find(params[:id])
     
    @receiptinsurance.deleted = true
    # @receiptinsurance.deleteuser_id = current_user.id

    @receiptinsurance.transaction do
      @receiptinsurance.save
      updateofficecash @receiptinsurance.total, @receiptinsurance.created_at.strftime('%d-%m-%Y') 
    end
    
    redirect_to(cashiers_path(:date => @receiptinsurance.created_at.strftime('%d-%m-%Y')))
  end  

end
