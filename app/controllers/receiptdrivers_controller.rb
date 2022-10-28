class ReceiptdriversController < ApplicationController
include ApplicationHelper
layout "application"
before_filter :authenticate_user!, :set_section

	def set_section
		@section = "cashiers"
	end

	def new
			@receiptdriver = Receiptdriver.new
			@errors = Hash.new
			@driverexpense_id = params[:driverexpense_id]
			@driverexpense = Driverexpense.find(params[:driverexpense_id]) rescue nil

		 respond_to :html
	end

	def create
		@receiptdriver = Receiptdriver.new
		@errors = Hash.new
		inputs = params[:receiptdriver]
		@driverexpense = Driverexpense.find(inputs[:driverexpense_id]) rescue nil

		@receiptdriver.driverexpense_id = inputs[:driverexpense_id]
		@receiptdriver.weight_loss = @driverexpense.weight_loss
		@receiptdriver.accident = @driverexpense.accident
		@receiptdriver.sparepart = @driverexpense.sparepart
		@receiptdriver.bon = @driverexpense.bon
		@receiptdriver.total = @driverexpense.total
		@receiptdriver.user_id = current_user.id

		receipt_exist = Receiptdriver.where(:sale_id => inputs[:driverexpense_id], :deleted => false).first rescue nil
		
		if receipt_exist.nil?

			if @receiptdriver.save

				if !@driverexpense.driver_id.nil?
					driver = Driver.find(@driverexpense.driver_id) rescue nil
					if driver
						driver.weight_loss += @receiptdriver.weight_loss
						driver.accident += @receiptdriver.accident
						driver.sparepart += @receiptdriver.sparepart
						driver.bon = @receiptdriver.bon
						driver.save
					end
				else
					helper = Helper.find(@driverexpense.helper_id) rescue nil
					if helper
						helper.weight_loss += @receiptdriver.weight_loss
						helper.accident += @receiptdriver.accident
						helper.sparepart += @receiptdriver.sparepart
						helper.bon = @receiptdriver.bon
						helper.save
					end
				end

				updateofficecash @receiptdriver.total * -1

				redirect_to(cashiers_path, :notice => 'Kas Supir No. ' + zeropad(inputs[:driverexpense_id]) + ' sukses di tambah.')
			else
				@driverexpense_id = inputs[:driverexpense_id]
				render :action => "new"
			end

		else
			redirect_to(cashiers_url)
		end
	end

	def edit
		@receiptdriver = Receiptdriver.find(params[:id]) rescue nil
		@errors = Hash.new
	end
		
	def update
		@errors = Hash.new
		inputs = params[:receiptdriver]
		@receipt = Receiptdriver.find(inputs[:receiptdriver_id]) rescue nil

		past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
		if past_date != inputs[:created_at]
			#updateofficecash @receipt.total, past_date

			datestring = inputs[:created_at].split('-')
			present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
			#updateofficecash @receipt.total * -1, present_date.strftime('%d-%m-%Y')
			
			@receipt.created_at = present_date
			@receipt.save
			redirect_to(cashiers_path, :notice => 'Kas Supir No. ' + zeropad(inputs[:receiptdriver_id]) + ' sukses di tambah.')
		else
			redirect_to(cashiers_path)
		end
	end

	def destroy
		@receipt = Receiptdriver.find(params[:id]) rescue nil
		@user = User.where(:username => session[:username]).first rescue nil
		
		if @receipt
			@receipt.deleted = true
			@receipt.deleteuser_id = @user.id if !@user.nil?
			@receipt.save

			updateofficecash @receipt.total, @receipt.created_at.strftime('%d-%m-%Y') 

			redirect_to(cashiers_url)
		end
	end

end