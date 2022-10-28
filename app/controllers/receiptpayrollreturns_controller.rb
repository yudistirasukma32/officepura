class ReceiptpayrollreturnsController < ApplicationController
	include ApplicationHelper
	layout "application"
		before_filter :authenticate_user!, :set_section

		def set_section
		@section = "cashiers"
		@where = "receiptpayrollreturns"
	end

	def index
	end

	def new
		@receiptpayrollreturn = Receiptpayrollreturn.new
			@errors = Hash.new
			@payroll_id = params[:payrollreturn_id]
			@payrollreturn = Payrollreturn.find(params[:payrollreturn_id]) rescue nil
		end

	def create
		@receiptpayrollreturn = Receiptpayrollreturn.new
		@errors = Hash.new

		inputs = params[:receiptpayrollreturn]

		@payrollreturn = Payrollreturn.find(inputs[:payrollreturn_id]) rescue nil

		@receiptpayrollreturn.user_id = current_user.id
		@receiptpayrollreturn.payroll_id = @payrollreturn.payroll_id
		@receiptpayrollreturn.holidays_payment = @payrollreturn.holidays_payment
		@receiptpayrollreturn.non_holidays_payment = @payrollreturn.non_holidays_payment
		@receiptpayrollreturn.weight_loss = @payrollreturn.weight_loss
		@receiptpayrollreturn.accident = @payrollreturn.accident
		@receiptpayrollreturn.sparepart = @payrollreturn.sparepart
		@receiptpayrollreturn.bon = @payrollreturn.bon
		@receiptpayrollreturn.allowance = @payrollreturn.allowance
		@receiptpayrollreturn.saving = @payrollreturn.saving
		@receiptpayrollreturn.saving_reduction = @payrollreturn.saving_reduction
		@receiptpayrollreturn.bonus = @payrollreturn.bonus
		@receiptpayrollreturn.total = @payrollreturn.total

    receipt_exist = Receiptpayrollreturn.where(:payroll_id => @payrollreturn.payroll_id, :deleted => false).first rescue nil
		if receipt_exist.nil?
			@receiptpayrollreturn.save

			updateofficecash @receiptpayrollreturn.total

			if !@payrollreturn.payroll.driver_id.nil?
				driver = Driver.find(@receiptpayrollreturn.payroll.driver_id) rescue nil
				if driver
					driver.weight_loss += @receiptpayrollreturn.weight_loss
					driver.accident += @receiptpayrollreturn.accident
					driver.sparepart += @receiptpayrollreturn.sparepart
					driver.bon += @receiptpayrollreturn.bon
					driver.saving -= @receiptpayrollreturn.saving
					driver.saving += @receiptpayrollreturn.saving_reduction
					driver.save
				end
			else
				helper = Helper.find(@receiptpayrollreturn.payroll.helper_id) rescue nil
				if helper
					helper.weight_loss -= @receiptpayrollreturn.weight_loss
					helper.accident -= @receiptpayrollreturn.accident
					helper.sparepart -= @receiptpayrollreturn.sparepart
					helper.bon -= @receiptpayrollreturn.bon
					helper.saving += @receiptpayrollreturn.saving
					helper.saving -= @receiptpayrollreturn.saving_reduction
					helper.save
				end
			end

			redirect_to(cashiers_path, :notice => 'BKM Supir No. ' + zeropad(inputs[:payrollreturn_id]) + ' sukses di tambah.')	
    else
      redirect_to(cashiers_url)
		end

	end

	def edit
		@errors = Hash.new
		@receiptpayrollreturn = Receiptpayrollreturn.find(params[:id]) rescue nil
	end

	def update
		@errors = Hash.new
		inputs = params[:receiptpayrollreturn]
		@receipt = Receiptpayrollreturn.find(inputs[:receiptpayrollreturn_id]) rescue nil

		past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
		if past_date != inputs[:created_at]
			#updatecashdailylog @receipt.total * -1, past_date

			datestring = inputs[:created_at].split('-')
			present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
			#updatecashdailylog @receipt.total, present_date.strftime('%d-%m-%Y')

			@receipt.created_at = present_date
			@receipt.save
			redirect_to(cashiers_path, :notice => 'Kasir BKM Supir No. ' + zeropad(inputs[:receiptpayrollreturn_id]) + ' sukses di tambah.')
		else
			redirect_to(cashiers_path)
		end
	end

	def destroy
		@receiptpayrollreturn = Receiptpayrollreturn.find(params[:id])

		@receiptpayrollreturn.deleted = true
		@receiptpayrollreturn.deleteuser_id = current_user.id
		
		if @receiptpayrollreturn.save
			
			if !@receiptpayrollreturn.payroll.driver_id.nil?
				driver = Driver.find(@receiptpayrollreturn.payroll.driver_id) rescue nil				
				if driver
					driver.weight_loss -= @receiptpayrollreturn.weight_loss
					driver.accident -= @receiptpayrollreturn.accident
					driver.sparepart -= @receiptpayrollreturn.sparepart
					driver.bon -= @receiptpayrollreturn.bon
					driver.saving += @receiptpayrollreturn.saving
					driver.saving -= @receiptpayrollreturn.saving_reduction
					driver.save
				end
			else
				helper = Helper.find(@receiptpayrollreturn.payroll.helper_id) rescue nil
				if helper
					helper.weight_loss -= @receiptpayrollreturn.weight_loss
					helper.accident -= @receiptpayrollreturn.accident
					helper.sparepart -= @receiptpayrollreturn.sparepart
					helper.bon -= @receiptpayrollreturn.bon
					helper.saving += @receiptpayrollreturn.saving
					helper.saving -= @receiptpayrollreturn.saving_reduction
					helper.save
				end
			end

			updateofficecash @receiptpayrollreturn.total * -1, @receiptpayrollreturn.created_at.strftime('%d-%m-%Y')   

			redirect_to(cashiers_path)
		else
			redirect_to(cashiers_path, :notice => 'Konfirmasi BKM Supir No. ' + zeropad(params[:id]) + ' gagal di hapus')
		end
	end
end