class DriverlogsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

	def set_section
		@section = "logs"
		@where = "driverlogs"
	end

	def index
		@drivers = Driver.where(:deleted => false).order("enabled DESC, name")
	  respond_to :html
	end

 	
	def new
		@driver = Driver.find(params[:driver_id])
		@driverlog = Driverlog.new
		@driverlog.driver_id = @driver.id
		@driverlog.ready = !@driver.enabled

		if @driver.enabled
			@status = "Tidak Ready"
		else
		  	@status = "Ready"
		end
	end

	def create
		inputs =params[:driverlog]
		@driverlog = Driverlog.new(inputs)
		@driver = Driver.find(inputs[:driver_id])

		if @driverlog.save
			@driver.enabled = @driverlog.ready
			@driver.save
			redirect_to(driverlogs_url, :notice => 'Data Status ' + @driver.name + ' sukses disimpan')
		else
			to_flash(@driverlog)
			render :action => "new"
		end

	end
end
