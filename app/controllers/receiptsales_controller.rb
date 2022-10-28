class ReceiptsalesController < ApplicationController
	include ApplicationHelper
	include ActionView::Helpers::NumberHelper
	layout "application", :except => []
	before_filter :authenticate_user!, :set_section
	
	def set_section
		@section = "cashiers"
	end

	def new
	    @receiptsale = Receiptsale.new
	    @errors = Hash.new
	    @sale_id = params[:sale_id]
	    @sale = Sale.find(params[:sale_id]) rescue nil
	end

	def create
	    @receiptsale = Receiptsale.new
	    @errors = Hash.new
	    inputs = params[:receiptsale]
	    @sale = Sale.find(inputs[:sale_id]) rescue nil

	  	@receiptsale.sale_id = inputs[:sale_id]
	    @receiptsale.total = @sale.saleitems.sum(:total)
	    @receiptsale.user_id = current_user.id

	    receipt_exist = Receiptsale.where(:sale_id => inputs[:sale_id], :deleted => false).first rescue nil
        if receipt_exist.nil?
          if @receiptsale.save
	    	updateofficecash @receiptsale.total
	        redirect_to(cashiers_path, :notice => 'Penjualan No. ' + zeropad(inputs[:sale_id]) + ' sukses di tambah.')
		  else
	    	@sale_id = inputs[:sale_id]
      		render :action => "new"
		  end
        else
          redirect_to(cashiers_url)
        end
	end

	def edit
	    @receiptsale = Receiptsale.find(params[:id]) rescue nil
	    @errors = Hash.new
	end
   	
	def update
	    @errors = Hash.new
	    inputs = params[:receiptsale]
	    @receipt = Receiptsale.find(inputs[:receiptsale_id]) rescue nil

	    past_date = @receipt.created_at.to_date.strftime('%d-%m-%Y')
	    if past_date != inputs[:created_at]
	      updatecashdailylog @receipt.total * -1, past_date

	      datestring = inputs[:created_at].split('-')
      	  present_date = DateTime.new(datestring[2].to_i, datestring[1].to_i, datestring[0].to_i)
	      updatecashdailylog @receipt.total, present_date.strftime('%d-%m-%Y')

	      @receipt.created_at = present_date
	      @receipt.save
	      redirect_to(cashiers_path, :notice => 'Kasir Penjualan No. ' + zeropad(inputs[:receiptsale_id]) + ' sukses di tambah.')
	    else
	      redirect_to(cashiers_path)
	    end
	end

   	def destroy
   		@receiptsale = Receiptsale.find(params[:id]) rescue nil
   		
   		if @receiptsale
   			@receiptsale.deleted = true
   			@receiptsale.deleteuser_id = current_user.id
   			updateofficecash @receiptsale.total * -1, @receiptsale.created_at.strftime('%d-%m-%Y')   
			@receiptsale.save

			redirect_to(cashiers_path)
   		end
   	end
end