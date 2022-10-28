class DriverexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  	before_filter :authenticate_user!, :set_section

	def set_section
		@section = "transactions"
		@where = "driverexpenses"
		@types = ['Driver', 'Helper']
	end

	def index
		@date = params[:date]
    	@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    	@driverexpenses = Driverexpense.where('date = ?', @date.to_date).order(:id)
	end

	def new
		@errors = Hash.new
	   
	    @driverexpense = Driverexpense.new
	    @driverexpense.date = Date.today.strftime('%d-%m-%Y')
	    @driverexpense.office_id = current_user.office_id rescue nil || 1 
	  	respond_to :html
	end

	def create
		inputs = params[:driverexpense]
		@driverexpense = Driverexpense.new

		if inputs[:type_driver] == 'd'
			driver = Driver.find(inputs[:driver_id]) rescue nil
			@driverexpense.driver_id = inputs[:driver_id]
		else
			helper = Helper.find(inputs[:driver_id]) rescue nil
			@driverexpense.helper_id = inputs[:driver_id]
		end	

		@driverexpense.office_id = inputs[:office_id]
		@driverexpense.date = inputs[:date]
		@driverexpense.description = inputs[:description]
		@driverexpense.weight_loss = inputs[:weight_loss]
		@driverexpense.accident = inputs[:accident]
		@driverexpense.sparepart = inputs[:sparepart]
		@driverexpense.bon = inputs[:bon]
		@driverexpense.total = @driverexpense.weight_loss.to_i + @driverexpense.accident.to_i + @driverexpense.sparepart.to_i + @driverexpense.bon.to_i
		@driverexpense.user_id = current_user.id
		if @driverexpense.save
	      redirect_to(driverexpenses_url, :notice => 'Kas Supir sukses di tambah.')
	    else
	      to_flash(@driverexpense)
	      render :action => "new"
	    end
	end

	def edit
		@errors = Hash.new
	   
	    @driverexpense = Driverexpense.find(params[:id])
	    @driverexpense.date = Date.today.strftime('%d-%m-%Y')
	    @driverexpense.total = @driverexpense.total.to_i
	    respond_to :html
	end

	def update
		inputs = params[:driverexpense]
	    @driverexpense = Driverexpense.find(params[:id])
	    
	    puts inputs[:type_driver]
	   		
    	if inputs[:type_driver] == 'd'
			driver = Driver.find(inputs[:driver_id]) rescue nil
			@driverexpense.driver_id = inputs[:driver_id]
		else
			helper = Helper.find(inputs[:driver_id]) rescue nil
			@driverexpense.helper_id = inputs[:driver_id]
		end	
		@driverexpense.office_id = inputs[:office_id]
		@driverexpense.date = inputs[:date]
		@driverexpense.description = inputs[:description]
		@driverexpense.weight_loss = inputs[:weight_loss]
		@driverexpense.accident = inputs[:accident]
		@driverexpense.sparepart = inputs[:sparepart]
		@driverexpense.bon = inputs[:bon]
		@driverexpense.total = @driverexpense.weight_loss.to_i + @driverexpense.accident.to_i + @driverexpense.sparepart.to_i + @driverexpense.bon.to_i
		@driverexpense.user_id = current_user.id
		
		if @driverexpense.save
			redirect_to(driverexpenses_url, :notice => 'Kas Supir sukses di simpan.')
	    else
			to_flash(@driverexpense)
			render :action => "edit"
	    end
	end

	def destroy
		@driverexpense = Driverexpense.find(params[:id])
	    
	    if @driverexpense.receiptdrivers.where(:deleted => false).any?
	      redirect_to(officeexpenses_url, :notice => 'Kas Supir No. #' + zeropad(@driverexpense.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
	    else
	      @driverexpense.deleteuser_id = current_user.id
	      @driverexpense.deleted = true
	      @driverexpense.save
	      redirect_to(driverexpenses_url)
	    end
	end

	def getdrivers
		render :json => { :success => true, :html => render_to_string(:partial => "driverexpenses/driver"), :layout => false }.to_json;
	end
end