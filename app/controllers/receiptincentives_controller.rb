class ReceiptincentivesController < ApplicationController
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
		@receiptincentives = Receiptincentive.where('date = ? AND deleted = false', @date.to_date)		
	end

	def new
		@errors = Hash.new
		@receiptincentive = Receiptincentive.new
		@invoice = Invoice.find(params[:invoice_id]) rescue nil
		@incentive = Incentive.where(:deleted => false, :invoice_id => params[:invoice_id]).first
	end

	def create
		@receiptincentive = Receiptincentive.new
		@errors = Hash.new
		inputs = params[:receiptincentive]
		@invoice = Invoice.find(inputs[:invoice_id]) rescue nil
		@incentive = Incentive.where(:deleted => false, :invoice_id => inputs[:invoice_id]).first

		if inputs[:process] == 'create'
			if checkavailableofficecash(@incentive.total) == true
				@receiptincentive.invoice_id = inputs[:invoice_id]
				@receiptincentive.incentive_id = @incentive.id
				@receiptincentive.date = Date.today.strftime('%d-%m-%Y')
				@receiptincentive.total = @incentive.total
				@receiptincentive.user_id = current_user.id
				
				receipt_exist = Receiptincentive.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil
				if receipt_exist.nil?
					@receiptincentive.save
						updateofficecash @receiptincentive.total * -1
						redirect_to(cashiers_path, :notice => 'Insentif No. ' + zeropad(@receiptincentive.id) + ' sukses di tambah.')
				else
					redirect_to(cashiers_url)
				end

			else
				@invoice_id = inputs[:invoice_id]
					@errors["receiptincentive"] = 'Insentif gagal disimpan, uang kas tidak memenuhi.'
					render :action => "new"	    			
			end
		else
			@invoice_id = inputs[:invoice_id]
				render :action => "new"
		end  
	end

	def edit
		@errors = Hash.new
		@receiptincentive = Receiptincentive.find(params[:id]) rescue nil
	end

	def update
		@errors = Hash.new
		inputs = params[:receiptincentive]
		@receipt = Receiptincentive.find(inputs[:receiptincentive_id]) rescue nil

		past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
		if past_date != inputs[:created_at]
			updatecashdailylog @receipt.total, past_date

			datestring = inputs[:created_at].split('-')
				present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
			updatecashdailylog @receipt.total * -1, present_date.strftime('%d-%m-%Y')

			@receipt.created_at = present_date
			@receipt.date = present_date.strftime('%d-%m-%Y')
			@receipt.save
			
			redirect_to(cashiers_path, :notice => 'Kasir Incentive No. ' + zeropad(inputs[:receiptincentive_id]) + ' sukses di tambah.')
		else
			redirect_to(cashiers_path)
		end
	end

	def destroy
		@receiptincentive = Receiptincentive.find(params[:id])
		
		updateofficecash @receiptincentive.total, @receiptincentive.created_at.strftime('%d-%m-%Y')  
		@receiptincentive.deleted = true
		@receiptincentive.deleteuser_id = current_user.id
		@receiptincentive.save
		redirect_to(cashiers_path)
	end
end
