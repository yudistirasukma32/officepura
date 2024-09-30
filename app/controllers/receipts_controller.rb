class ReceiptsController < ApplicationController
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
    @receipts = Receipt.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    @dateshow = Date.today.strftime('%b %Y')
    respond_to :html
  end

  def new
    @receipt = Receipt.new
    @errors = Hash.new
    @invoice_id = params[:invoice_id]
    @invoice = Invoice.find(params[:invoice_id]) rescue nil
  end

  def create
    @receipt = Receipt.new
    @errors = Hash.new
    inputs = params[:receipt]
    @invoice = Invoice.find(inputs[:invoice_id]) rescue nil

    if inputs[:process] == 'create'
      if checkavailableofficecash(@invoice.total) == true
        @receipt.invoice_id = inputs[:invoice_id]
        @receipt.office_id = @invoice.office_id
        @receipt.quantity = @invoice.quantity
        @receipt.driver_allowance = @invoice.driver_allowance.to_i
        @receipt.helper_allowance = @invoice.helper_allowance.to_i
        @receipt.misc_allowance = @invoice.misc_allowance.to_i
        @receipt.ferry_fee = @invoice.ferry_fee.to_i
        @receipt.tol_fee = @invoice.tol_fee.to_i
        @receipt.gas_allowance = @invoice.gas_allowance
        @receipt.premi_allowance = @invoice.premi_allowance.to_i
        @receipt.total = @invoice.total
        @receipt.user_id = current_user.id

        # render json: ([5,3,6,7].include? @invoice.office_id.to_i)
        # return false
        if ([99].include? @invoice.office_id)

          @receipt.driver_allowance = 0
          @receipt.helper_allowance = 0
          @receipt.misc_allowance = 0
          @receipt.ferry_fee = 0
          @receipt.tol_fee = 0
          @receipt.gas_allowance = 0
          @receipt.premi_allowance = 0
          @receipt.total = 0

        end

        receipt_exist = Receipt.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil
        if receipt_exist.nil?
          @receipt.transaction do
            if @receipt.save
              updateofficecash @receipt.total * -1

              @driver = Driver.find(@invoice.driver_id)
              if !@driver.nil?
                # @driver.enabled = false
                # 2022 Updated
                @driver.enabled = true
                
                if @driver.save
                  @driverlog = Driverlog.new
                  @driverlog.driver_id = @driver.id
                  @driverlog.ready = true
                  @driverlog.description = 'Jalan BKK #'+ zeropad(@invoice.id) + ': ' + @invoice.route.name + ' (' + @invoice.vehicle.current_id + ')'
                  @driverlog.save
                end
              end

              @vehicle = Vehicle.find(@invoice.vehicle_id)
              if !@vehicle.nil?
                # @vehicle.enabled = false
                # 2022 Updated
                @vehicle.enabled = true
                
                if @vehicle.save
                  @vehiclelog = Vehiclelog.new
                  @vehiclelog.vehicle_id = @vehicle.id
                  @vehiclelog.ready = true
                  @vehiclelog.description = 'Jalan BKK #'+ zeropad(@invoice.id) + ': ' + @invoice.route.name + ' (' + @invoice.driver.name + ')'
                  @vehiclelog.save
                end
              end
            end
          end

          # recount event stats
          if @invoice.event_id.present?
            updateinvoiceconfirmed_count @invoice.event_id
          end

          redirect_to(cashiers_path(:date => @invoice.date.strftime('%d-%m-%Y')), :notice => 'BKK No. ' + zeropad(inputs[:invoice_id]) + ' sukses di tambah.')
        else
          redirect_to(cashiers_url)
        end
      
      else
        @invoice_id = inputs[:invoice_id]
        @errors["receipt"] = 'BKK No. ' + zeropad(inputs[:invoice_id]) + ' gagal di tambah, uang kas tidak memenuhi'
        render :action => "new", :notice => 'BKK No. ' + zeropad(inputs[:invoice_id]) + ' gagal di tambah, uang kas tidak memenuhi'
      end
    else
      @invoice_id = inputs[:invoice_id]
      render :action => "new"
    end
  end

  def edit
    @errors = Hash.new
    @receipt = Receipt.find(params[:id]) rescue nil
  end

  def update
    @errors = Hash.new
    inputs = params[:receipt]
    @receipt = Receipt.find(inputs[:receipt_id]) rescue nil

    past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
    if past_date != inputs[:created_at]
      updatecashdailylog @receipt.total, past_date

      datestring = inputs[:created_at].split('-')
      present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
      updatecashdailylog @receipt.total * -1, present_date.strftime('%d-%m-%Y')

      @receipt.created_at = present_date
      @receipt.save
      redirect_to(cashiers_path(:date => @receipt.created_at.strftime('%d-%m-%Y')), :notice => 'Kasir BKK No. ' + zeropad(inputs[:receipt_id]) + ' sukses di tambah.')
    else
      redirect_to(cashiers_path(:date => @receipt.created_at.strftime('%d-%m-%Y')))
    end
  end

 def destroy
    @receipt = Receipt.find(params[:id])
     
    @receipt.deleted = true
    @receipt.deleteuser_id = current_user.id

    @receipt.transaction do
      @receipt.save
      updateofficecash @receipt.total, @receipt.created_at.strftime('%d-%m-%Y') 
    end
    
    redirect_to(cashiers_path(:date => @receipt.created_at.strftime('%d-%m-%Y')))
  end  

end
