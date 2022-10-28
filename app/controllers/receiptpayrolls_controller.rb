class ReceiptpayrollsController < ApplicationController
	include ApplicationHelper
	layout "application"
		before_filter :authenticate_user!, :set_section

		def set_section
		@section = "cashiers"
		@where = "receiptpayrolls"
	end

	def index
	end

	def new
		@receiptpayroll = Receiptpayroll.new
			@errors = Hash.new
			@payroll_id = params[:payroll_id]
			@payroll = Payroll.find(params[:payroll_id]) rescue nil
		end

	def create
		@receiptpayroll = Receiptpayroll.new
		@errors = Hash.new
		inputs = params[:receiptpayroll]
		@payroll = Payroll.find(inputs[:payroll_id]) rescue nil

		if checkavailableofficecash(@payroll.total) == true
			@receiptpayroll.user_id = current_user.id
			@receiptpayroll.payroll_id = @payroll.id
			@receiptpayroll.holidays_payment = @payroll.holidays_payment
			@receiptpayroll.non_holidays_payment = @payroll.non_holidays_payment
			@receiptpayroll.weight_loss = @payroll.weight_loss
			@receiptpayroll.accident = @payroll.accident
			@receiptpayroll.sparepart = @payroll.sparepart
			@receiptpayroll.bon = @payroll.bon
			@receiptpayroll.allowance = @payroll.allowance
			@receiptpayroll.saving = @payroll.saving
			@receiptpayroll.saving_reduction = @payroll.saving_reduction
			@receiptpayroll.bonus = @payroll.bonus
			@receiptpayroll.total = @payroll.total

      receipt_exist = Receiptpayroll.where(:payroll_id => @payroll.id, :deleted => false).first rescue nil
			if receipt_exist.nil?				
				@receiptpayroll.save

				updateofficecash @receiptpayroll.total * -1

				if !@payroll.driver_id.nil?
					driver = Driver.find(@payroll.driver_id) rescue nil
					if driver
						driver.weight_loss -= @payroll.weight_loss.to_f
						driver.accident = driver.accident.to_f - @payroll.accident.to_f
						driver.sparepart -= @payroll.sparepart.to_f
						driver.bon -= @payroll.bon.to_f
						driver.saving += @payroll.saving.to_f
						driver.saving -= @payroll.saving_reduction.to_f
						driver.save
					end
				else
					helper = Helper.find(@payroll.helper_id) rescue nil
					if helper
						helper.weight_loss -= @payroll.weight_loss.to_f
						helper.accident -= @payroll.accident.to_i
						helper.sparepart -= @payroll.sparepart.to_f
						helper.bon -= @payroll.bon.to_f
						helper.saving += @payroll.saving.to_f
						helper.saving -= @payroll.saving_reduction.to_f
						helper.save
					end
				end
			
				redirect_to(cashiers_path, :notice => 'BKK Supir No. ' + zeropad(inputs[:payroll_id]) + ' sukses di tambah.')
      else
        redirect_to(cashiers_url)
			end

		else
			@payroll_id = inputs[:payroll_id]

			render :action => "new", :notice => 'BKK Supir No. ' + zeropad(inputs[:payroll_id]) + ' gagal di tambah, uang kas tidak memenuhi'
		end
	end

	def edit
		@errors = Hash.new
		@receiptpayroll = Receiptpayroll.find(params[:id]) rescue nil
	end

	def update
		@errors = Hash.new
		inputs = params[:receiptpayroll]
		@receipt = Receiptpayroll.find(inputs[:receiptpayroll_id]) rescue nil

		past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
		if past_date != inputs[:created_at]
			#updatecashdailylog @receipt.total, past_date

			datestring = inputs[:created_at].split('-')
			present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
			#updatecashdailylog @receipt.total * -1, present_date.strftime('%d-%m-%Y')

			@receipt.created_at = present_date
			@receipt.save
			redirect_to(cashiers_path, :notice => 'Kasir BKK Supir No. ' + zeropad(inputs[:receiptpayroll_id]) + ' sukses di tambah.')
		else
			redirect_to(cashiers_path)
		end
	end

	def destroy
		@receiptpayroll = Receiptpayroll.find(params[:id])

		@receiptpayroll.deleted = true
		@receiptpayroll.deleteuser_id = current_user.id
		if @receiptpayroll.save
			if !@receiptpayroll.payroll.driver_id.nil?
				driver = Driver.find(@receiptpayroll.payroll.driver_id) rescue nil
				if driver
					driver.weight_loss += @receiptpayroll.weight_loss.to_f
					driver.accident += @receiptpayroll.accident.to_f
					driver.sparepart += @receiptpayroll.sparepart.to_f
					driver.bon += @receiptpayroll.bon.to_f
					driver.saving -= @receiptpayroll.saving.to_f
					driver.saving += @receiptpayroll.saving_reduction.to_f
					driver.save
				end
			else
				helper = Helper.find(@receiptpayroll.payroll.helper_id) rescue nil
				if helper
					helper.weight_loss += @receiptpayroll.weight_loss.to_f
					helper.accident += @receiptpayroll.accident.to_f
					helper.sparepart += @receiptpayroll.sparepart.to_f
					helper.bon += @receiptpayroll.bon.to_f
					helper.saving -= @receiptpayroll.saving.to_f
					helper.saving += @receiptpayroll.saving_reduction.to_f
					helper.save
				end
			end

			updateofficecash @receiptpayroll.total, @receiptpayroll.created_at.strftime('%d-%m-%Y')   
			
			redirect_to(cashiers_path)
		else
			redirect_to(cashiers_path, :notice => 'Konfirmasi BKK Supir No. ' + zeropad(params[:id]) + ' gagal di hapus')
		end
	end
end