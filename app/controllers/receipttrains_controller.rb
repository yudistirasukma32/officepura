class ReceipttrainsController < ApplicationController
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
    @receipttrains = Receipttrain.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    @dateshow = Date.today.strftime('%b %Y')
    respond_to :html
  end

  def new
    @receipttrain = Receipttrain.new
    @errors = Hash.new
    @trainexpense_id = params[:trainexpense_id]
    @trainexpense = Trainexpense.find(params[:trainexpense_id]) rescue nil
  end

  def create
    @receipttrain = Receipttrain.new
    @errors = Hash.new
    inputs = params[:receipttrain]
    @trainexpense = Trainexpense.find(inputs[:trainexpense_id]) rescue nil

      if checkavailableofficecash(@trainexpense.total) == true
        @receipttrain.trainexpense_id = inputs[:trainexpense_id]
        @receipttrain.office_id = @trainexpense.invoice.office_id
        @receipttrain.misc_total = @trainexpense.misc_total.to_i
        @receipttrain.gst_tax = @trainexpense.gst_tax.to_i
        @receipttrain.gst_percentage = @trainexpense.gst_tax.to_i > 0 ? 11 : 0
        @receipttrain.total = @trainexpense.total.to_i
        @receipttrain.user_id = current_user.id
        @receipttrain.expensetype = @trainexpense.expensetype

        receipt_exist = Receipttrain.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil
        if receipt_exist.nil?
          @receipttrain.transaction do
            if @receipttrain.save
              updateofficecash @receipttrain.total * -1
              redirect_to(cashiers_path(:date => @trainexpense.date.strftime('%d-%m-%Y')), :notice => 'Biaya Kereta No. ' + zeropad(inputs[:trainexpense_id]) + ' sukses ditambah.')
            end
          end
        end

      else
        @trainexpense_id = inputs[:trainexpense_id]
        @errors["receipttrain"] = 'Biaya Kereta No. ' + zeropad(inputs[:trainexpense_id]) + ' gagal ditambah, uang kas tidak memenuhi'
        render :action => "new", :notice => 'Biaya Kereta No. ' + zeropad(inputs[:trainexpense_id]) + ' gagal ditambah, uang kas tidak memenuhi'
      end

  end

  def edit
    @errors = Hash.new
    @receipttrain = Receipttrain.find(params[:id]) rescue nil
  end

  def update
    @errors = Hash.new
    inputs = params[:receipt]
    @receipttrain = Receipttrain.find(inputs[:receipt_id]) rescue nil

    past_date = @receipttrain.created_at.to_date.strftime('%d-%m-%Y')
    if past_date != inputs[:created_at]
      updatecashdailylog @receipttrain.total, past_date

      datestring = inputs[:created_at].split('-')
      present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
      updatecashdailylog @receipttrain.total * -1, present_date.strftime('%d-%m-%Y')

      @receipttrain.created_at = present_date
      @receipttrain.save
      redirect_to(cashiers_path(:date => @receipttrain.created_at.strftime('%d-%m-%Y')), :notice => 'Kasir BKK No. ' + zeropad(inputs[:receipt_id]) + ' sukses di tambah.')
    else
      redirect_to(cashiers_path(:date => @receipttrain.created_at.strftime('%d-%m-%Y')))
    end
  end

 def destroy
    @receipttrain = Receipttrain.find(params[:id])
     
    @receipttrain.deleted = true
    @receipttrain.deleteuser_id = current_user.id

    @receipttrain.transaction do
      @receipttrain.save
      updateofficecash @receipttrain.total, @receipttrain.created_at.strftime('%d-%m-%Y') 
    end
    
    redirect_to(cashiers_path(:date => @receipttrain.created_at.strftime('%d-%m-%Y')))
  end  

end
