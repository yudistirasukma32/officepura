class ReceiptordersController < ApplicationController
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
		@receiptorders = Receiptorder.where('date = ? AND deleted = false', @date.to_date)
	end

	def new
		@errors = Hash.new
		@receiptorder = Receiptorder.new
		@productorder_id = params[:productorder_id]
		@totalbon = 0
	    @totalcash = 0
		@productorder = Productorder.find(params[:productorder_id]) rescue nil	
		@orderbon = Productorderitem.where(:productorder_id => params[:productorder_id], :bon => true)
		if !@orderbon.first.nil?
			@totalbon = @orderbon.sum(:total)
		end

		@ordercash = Productorderitem.where(:productorder_id => params[:productorder_id], :bon => false)
		if !@ordercash.first.nil?
			@totalcash = @ordercash.sum(:total)
		end
	end

	def create
		@errors = Hash.new
	    @receiptorder = Receiptorder.new
	    @totalbon = 0
	    @totalcash = 0

	    inputs = params[:receiptorder]
	    @productorder = Productorder.find(inputs[:productorder_id]) rescue nil
	    @orderbon = Productorderitem.where(:productorder_id => inputs[:productorder_id], :bon => true)
		if !@orderbon.first.nil?
			@totalbon = @orderbon.sum(:total)
		end

		@ordercash = Productorderitem.where(:productorder_id => inputs[:productorder_id], :bon => false)
		if !@ordercash.first.nil?
			@totalcash = @ordercash.sum(:total)
		end
    
    	if inputs[:process] == 'create'
    		if @totalcash > 0
	    		if checkavailableofficecash(@totalcash) == true
		    		@receiptorder.productorder_id = inputs[:productorder_id]
		    		@receiptorder.date = Date.today.strftime('%d-%m-%Y')
		    		@receiptorder.total = @totalcash
		    		@receiptorder.bon = @totalbon
		    		@receiptorder.user_id = current_user.id

		    		receipt_exist = Receiptorder.where(:productorder_id => inputs[:productorder_id], :deleted => false).first rescue nil
					if receipt_exist.nil?
						@receiptorder.save

			    		updateofficecash @receiptorder.total * -1
			    		updatebudget @receiptorder.bon * -1
			    		redirect_to(cashiers_path, :notice => 'Order Pembelian No. ' + zeropad(inputs[:productorder_id]) + ' sukses di tambah.')
					else
						redirect_to(cashiers_url)
					end
		    		
	    		else
	    			@productorder_id= inputs[:productorder_id]
	      			@errors["receiptorder"] = 'Order Pembelian gagal disimpan, uang kas tidak memenuhi.'
	      			render :action => "new"
	    		end
	    	else
	    		@productorder_id= inputs[:productorder_id]
	      		@errors["receiptorder"] = 'Order Pembelian gagal disimpan, total pembelian sama dengan nol.'
	      		render :action => "new"
	    	end
    	else
    		@productorder_id= inputs[:productorder_id]
      		render :action => "new"
    	end
	end

	def edit
		@errors = Hash.new
		@receiptorder = Receiptorder.find(params[:id]) rescue nil
		@totalbon = 0
	    @totalcash = 0
		@productorder = Productorder.find(@receiptorder.productorder_id) rescue nil	
		@orderbon = Productorderitem.where(:productorder_id => @receiptorder.productorder_id, :bon => true)
		if !@orderbon.first.nil?
			@totalbon = @orderbon.sum(:total)
		end

		@ordercash = Productorderitem.where(:productorder_id => @receiptorder.productorder_id, :bon => false)
		if !@ordercash.first.nil?
			@totalcash = @ordercash.sum(:total)
		end
	end

	def update
	    @errors = Hash.new
	    inputs = params[:receiptorder]
	    @receipt = Receiptorder.find(inputs[:receiptorder_id]) rescue nil

	    past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
	    if past_date != inputs[:created_at]
	      updatecashdailylog @receipt.total, past_date

	      datestring = inputs[:created_at].split('-')
		  present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
	      updatecashdailylog @receipt.total * -1, present_date.strftime('%d-%m-%Y')

	      @receipt.created_at = present_date
	      @receipt.date = present_date.strftime('%d-%m-%Y')
	      @receipt.save
	      redirect_to(cashiers_path, :notice => 'Kasir Pembelian No. ' + zeropad(inputs[:receiptorder_id]) + ' sukses di tambah.')
	    else
	      redirect_to(cashiers_path)
	    end
	end

	def destroy
		@receiptorder = Receiptorder.find(params[:id])
		
	    updateofficecash @receiptorder.total, @receiptorder.created_at.strftime('%d-%m-%Y') 
	    updatebudget @receiptorder.bon
	    @receiptorder.deleted = true
	    @receiptorder.deleteuser_id = current_user.id
	    @receiptorder.save
	    redirect_to(cashiers_path)
	end
end
