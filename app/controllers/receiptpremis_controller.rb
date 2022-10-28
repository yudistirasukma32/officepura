class ReceiptpremisController < ApplicationController
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
		@receiptpremis = Receiptpremi.where('date = ? AND deleted = false', @date.to_date)		
	end

	def new
		@errors = Hash.new
		@receiptpremi = Receiptpremi.new
		@invoice = Invoice.find(params[:invoice_id]) rescue nil
		@bonusreceipt = Bonusreceipt.where(:deleted => false, :invoice_id => params[:invoice_id]).first
	end

	def create
		@receiptpremi = Receiptpremi.new
		@errors = Hash.new
		inputs = params[:receiptpremi]
		@invoice = Invoice.find(inputs[:invoice_id]) rescue nil
		@bonusreceipt = Bonusreceipt.where(:deleted => false, :invoice_id => inputs[:invoice_id]).first

		if inputs[:process] == 'create'
			if checkavailableofficecash(@bonusreceipt.total) == true
				@receiptpremi.invoice_id = inputs[:invoice_id]
				@receiptpremi.bonusreceipt_id = @bonusreceipt.id
				@receiptpremi.date = Date.today.strftime('%d-%m-%Y')
				@receiptpremi.total = @bonusreceipt.total
				@receiptpremi.user_id = current_user.id
				
				receipt_exist = Receiptpremi.where(:invoice_id => inputs[:invoice_id], :deleted => false).first rescue nil
				if receipt_exist.nil?
					@receiptpremi.save
		  			updateofficecash @receiptpremi.total * -1
		  			redirect_to(cashiers_path, :notice => 'Premi No. ' + zeropad(@receiptpremi.id) + ' sukses di tambah.')
				else
					redirect_to(cashiers_url)
				end

			else
				@invoice_id = inputs[:invoice_id]
					@errors["receiptpremi"] = 'Premi gagal disimpan, uang kas tidak memenuhi.'
					render :action => "new"	    			
			end
		else
			@invoice_id = inputs[:invoice_id]
		  	render :action => "new"
		end  
	end

	def edit
	    @errors = Hash.new
	    @receiptpremi = Receiptpremi.find(params[:id]) rescue nil
	end

	def update
	    @errors = Hash.new
	    inputs = params[:receiptpremi]
	    @receipt = Receiptpremi.find(inputs[:receiptpremi_id]) rescue nil

	    past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
	    if past_date != inputs[:created_at]
	      updatecashdailylog @receipt.total, past_date

	      datestring = inputs[:created_at].split('-')
          present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
	      updatecashdailylog @receipt.total * -1, present_date.strftime('%d-%m-%Y')

	      @receipt.created_at = present_date
	      @receipt.date = present_date.strftime('%d-%m-%Y')
	      @receipt.save
	      redirect_to(cashiers_path, :notice => 'Kasir Premi No. ' + zeropad(inputs[:receiptpremi_id]) + ' sukses di tambah.')
	    else
	      redirect_to(cashiers_path)
	    end
	end

	def destroy
		@receiptpremi = Receiptpremi.find(params[:id])
		
		updateofficecash @receiptpremi.total, @receiptpremi.created_at.strftime('%d-%m-%Y')  
		@receiptpremi.deleted = true
		@receiptpremi.deleteuser_id = current_user.id
		@receiptpremi.save
		redirect_to(cashiers_path)
	end
end
