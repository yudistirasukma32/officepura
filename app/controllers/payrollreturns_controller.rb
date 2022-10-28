class PayrollreturnsController < ApplicationController
	include ApplicationHelper
	layout "application"
  	before_filter :authenticate_user!, :set_section

  	def set_section
		@section = "transactions"
		@where = "payrollreturns"
	end

	def index
		@month = params[:month]
	    @month = "%02d" % Date.today.month.to_s if @month.nil?
	    @year = params[:year]
	    @year = Date.today.year if @year.nil?
	    @payrolls = Payroll.active.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}")
	    respond_to :html
	end

	def index_confirmed
		@month = params[:month]
	    @month = "%02d" % Date.today.month.to_s if @month.nil?
	    @year = params[:year]
	    @year = Date.today.year if @year.nil?
	    @payrollreturns = Payrollreturn.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}")
	    respond_to :html
	end

	def new
		@payrollreturn = Payrollreturn.new
		@payroll = Payroll.find(params[:payroll_id])
	end

	def create
		inputs = params[:payrollreturn]
		@payrollreturn = Payrollreturn.new
		@payroll = Payroll.find(inputs[:payroll_id])

		@payrollreturn.payroll_id = @payroll.id
		@payrollreturn.date = Date.today.strftime('%d-%m-%Y')
		@payrollreturn.user_id = current_user.id

		@payrollreturn.holidays_payment = @payroll.holidays_payment
		@payrollreturn.non_holidays_payment = @payroll.non_holidays_payment
		@payrollreturn.weight_loss = @payroll.weight_loss
		@payrollreturn.accident = @payroll.accident
		@payrollreturn.sparepart = @payroll.sparepart
		@payrollreturn.bon = @payroll.bon
		@payrollreturn.allowance = @payroll.allowance
		@payrollreturn.saving = @payroll.saving
		@payrollreturn.saving_reduction = @payroll.saving_reduction
		@payrollreturn.bonus = @payroll.bonus
		@payrollreturn.total = @payroll.total

		if @payrollreturn.save
			redirect_to(payrollreturns_url, :notice => 'Data BKM Supir sukses ditambah')
		else
			render :action => 'new'
		end

	end

	def edit
	end

	def destroy
		@payrollreturn = Payrollreturn.find(params[:id])
    
	    if @payrollreturn.payroll.receiptpayrollreturns.where(:deleted => false).any? 
	      redirect_to(payrollreturns_path, :notice => 'BKM Supir No. #' + zeropad(@payrollreturn.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
	    else
	      @payrollreturn.deleteuser_id = current_user.id
	      @payrollreturn.deleted = true
	      @payrollreturn.save
	      redirect_to(payrollreturns_url)
	    end
	end
end