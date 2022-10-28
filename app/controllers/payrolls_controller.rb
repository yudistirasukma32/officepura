class PayrollsController < ApplicationController
	include ApplicationHelper
	include ActionView::Helpers::NumberHelper
	layout "application"
  	before_filter :authenticate_user!, :set_section

  	def set_section
		@section = "transactions"
		@where = "payrolls"
	end

	def index
		@month = params[:month]
	    @month = "%02d" % Date.today.month.to_s if @month.nil?
	    @year = params[:year]
	    @year = Date.today.year if @year.nil?
	    @payrolls = Payroll.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}")
	    respond_to :html
	end

	def new
		@payroll = Payroll.new
		@payroll.date = Date.today.strftime('%d-%m-%Y')
		@payroll.office_id = current_user.office_id rescue nil || 1
		respond_to :html
	end

	def create
		inputs = params[:payroll]
		@payroll = Payroll.new

		if inputs[:type_driver] == 'd'
			driver = Driver.find(inputs[:driver_id]) rescue nil
			@payroll.driver_id = inputs[:driver_id]

			if driver.status == "Tetap"
				@payroll.non_holidays_fare = Setting.find_by_name("UH Supir").value.to_i rescue nil
			else
				@payroll.non_holidays_fare =  Setting.find_by_name("UH Warnen").value.to_i rescue nil
			end
			@payroll.holidays_fare = 2 * @payroll.non_holidays_fare
			@payroll.master_weight_loss = driver.weight_loss
			@payroll.master_accident = driver.accident
			@payroll.master_sparepart = driver.sparepart
			@payroll.master_bon = driver.bon
			@payroll.master_saving = driver.saving
			@payroll.vehicle_id = driver.vehicle_id
		else
			helper = Helper.find(inputs[:driver_id]) rescue nil
			@payroll.helper_id = inputs[:driver_id]

			@payroll.non_holidays_fare =  Setting.find_by_name("UH Kernet").value.to_i rescue nil
			@payroll.holidays_fare = 2 * @payroll.non_holidays_fare
			@payroll.master_weight_loss = helper.weight_loss
			@payroll.master_accident = helper.accident
			@payroll.master_sparepart = helper.sparepart
			@payroll.master_bon = helper.bon
			@payroll.master_saving = helper.saving
			@payroll.vehicle_id = helper.driver.vehicle_id
		end	

		@payroll.date = inputs[:date]
		date_period = @payroll.date.to_date - 1.month
		@payroll.period_start = date_period.at_beginning_of_month.strftime('%d-%m-%Y')
		@payroll.period_end = (date_period.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
		@payroll.office_id = inputs[:office_id]

		@payroll.non_holidays = inputs[:non_holidays]
		@payroll.non_holidays_payment = @payroll.non_holidays * @payroll.non_holidays_fare

		@payroll.holidays = inputs[:holidays]
		@payroll.holidays_payment = @payroll.holidays * @payroll.holidays_fare

		@payroll.saving_reduction = inputs[:saving_reduction]
		@payroll.bonus = inputs[:bonus]
		@payroll.helper_fee = inputs[:helper_fee]


		@payroll.weight_loss = inputs[:weight_loss]
		@payroll.accident = inputs[:accident]
		@payroll.sparepart = inputs[:sparepart]
		@payroll.bon = inputs[:bon]
		@payroll.saving = inputs[:saving]
		@payroll.allowance = inputs[:allowance]

		@payroll.total = @payroll.non_holidays_payment + @payroll.holidays_payment + @payroll.saving_reduction + @payroll.bonus + @payroll.helper_fee - @payroll.weight_loss - @payroll.accident - @payroll.sparepart - @payroll.bon - @payroll.saving - @payroll.allowance

		@payroll.user_id = current_user.id

		if @payroll.save
			redirect_to(confirmation_payroll_url(@payroll), :notice => 'Data BKK Supir sukses ditambah')
		else
			render :action => 'new'
		end
	end

	def edit
		@payroll = Payroll.find(params[:id])
		respond_to :html
	end

	def update
		inputs = params[:payroll]
		@payroll = Payroll.find(params[:id])

		if inputs[:type_driver] == 'd'
			driver = Driver.find(inputs[:driver_id]) rescue nil
			@payroll.driver_id = inputs[:driver_id]

			if driver.status == "Tetap"
				@payroll.non_holidays_fare = Setting.find_by_name("UH Supir").value.to_i rescue nil
			else
				@payroll.non_holidays_fare =  Setting.find_by_name("UH Warnen").value.to_i rescue nil
			end
			@payroll.holidays_fare = 2 * @payroll.non_holidays_fare
			@payroll.master_weight_loss = driver.weight_loss
			@payroll.master_accident = driver.accident
			@payroll.master_sparepart = driver.sparepart
			@payroll.master_bon = driver.bon
			@payroll.master_saving = driver.saving
			@payroll.vehicle_id = driver.vehicle_id
		else
			helper = Helper.find(inputs[:driver_id]) rescue nil
			@payroll.helper_id = inputs[:driver_id]

			@payroll.non_holidays_fare =  Setting.find_by_name("UH Kernet").value.to_i rescue nil
			@payroll.holidays_fare = 2 * @payroll.non_holidays_fare
			@payroll.master_weight_loss = helper.weight_loss
			@payroll.master_accident = helper.accident
			@payroll.master_sparepart = helper.sparepart
			@payroll.master_bon = helper.bon
			@payroll.master_saving = helper.saving
			@payroll.vehicle_id = helper.driver.vehicle_id
		end	

		@payroll.date = inputs[:date]
		date_period = @payroll.date.to_date - 1.month
		@payroll.period_start = date_period.at_beginning_of_month.strftime('%d-%m-%Y')
		@payroll.period_end = (date_period.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
		@payroll.office_id = inputs[:office_id]
		
		@payroll.non_holidays = inputs[:non_holidays]
		@payroll.non_holidays_payment = @payroll.non_holidays * @payroll.non_holidays_fare

		@payroll.holidays = inputs[:holidays]
		@payroll.holidays_payment = @payroll.holidays * @payroll.holidays_fare

		@payroll.saving_reduction = inputs[:saving_reduction]
		@payroll.bonus = inputs[:bonus]
		@payroll.helper_fee = inputs[:helper_fee]

		@payroll.weight_loss = inputs[:weight_loss]
		@payroll.accident = inputs[:accident]
		@payroll.sparepart = inputs[:sparepart]
		@payroll.bon = inputs[:bon]
		@payroll.saving = inputs[:saving]
		@payroll.allowance = inputs[:allowance]

		@payroll.total = @payroll.non_holidays_payment + @payroll.holidays_payment + @payroll.saving_reduction + @payroll.helper_fee + @payroll.bonus - @payroll.weight_loss - @payroll.accident - @payroll.sparepart - @payroll.bon - @payroll.saving - @payroll.allowance

		@payroll.user_id = current_user.id

		if @payroll.save
			redirect_to(confirmation_payroll_url(@payroll), :notice => 'Data BKK Supir sukses ditambah')
		else
			render :action => 'edit'
		end
	end

	def destroy
		 @payroll = Payroll.find(params[:id])
    
	    if @payroll.receiptpayrolls.where(:deleted => false).any? or @payroll.receiptpayrollreturns.where(:deleted => false).any? 
	      redirect_to(payrolls_path, :notice => 'BKK Supir No. #' + zeropad(@payroll.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
	    else
	      if @payroll.payrollreturns.any?
	        @payroll.payrollreturns.each do |payrollreturn|  
	          payrollreturn.deleted = true
	          payrollreturn.deleteuser_id = current_user.id
	          payrollreturn.save
	        end
	      end
	      
	      @payroll.deleteuser_id = current_user.id
	      @payroll.deleted = true
	      @payroll.save
	      redirect_to(payrolls_url)
	    end
	end

	def confirmation
		@payroll = Payroll.find(params[:id])
		
		respond_to :html
	end

	def getdrivers
		render :json => { :success => true, :html => render_to_string(:partial => "payrolls/driver"), :layout => false }.to_json;
	end

	def getdriverdata
		holiday_fare = 0
		non_holiday_fare = 0
		if params[:type] == 'd'
			@data = Driver.find(params[:id]) rescue nil
			if @data.status == "Tetap"
				non_holiday_fare = Setting.find_by_name("UH Supir").value.to_i
			else
				non_holiday_fare = Setting.find_by_name("UH Warnen").value.to_i
			end

			holiday_fare = 2 * non_holiday_fare
			
		else
			@data = Helper.find(params[:id]) rescue nil
			non_holiday_fare = Setting.find_by_name("UH Kernet").value.to_i
			holiday_fare = 2 * non_holiday_fare
		end
		
		render :json => { :success => true, :layout => false, 
			:non_holiday_fare => to_currency(non_holiday_fare),
			:holiday_fare => to_currency(holiday_fare),
			:weight_loss =>  to_currency(@data.weight_loss.to_i) || 0,
			:accident => to_currency(@data.accident.to_i) || 0,
			:sparepart => to_currency(@data.sparepart.to_i) || 0,
			:bon => to_currency(@data.bon.to_i) || 0,
			:saving => to_currency(@data.saving.to_i) || 0 }.to_json;
	end
end