class DriversapiController < ApplicationController
	def index
		@drivers = Driver.order('name').where("deleted = false")
		count_driver = @drivers.count
		
		@driverslist = @drivers.map do |u|
			
			img = u.images.first rescue nil
			
			@dLog = Driverlog.find_by_sql ["SELECT ready, absent, description from driverlogs where driver_id = ? order by created_at desc limit 1 ", params[:id]]		
			
			if !img.nil? and img.file_uid
				{ :id => u.id, :city => u.city, :enabled => u.enabled, :name => u.name, :mobile => u.mobile, :phone => u.phone,:imgUrl => u.images.first.file.thumb('240x240').url(:suffix => "/#{u.images.first.name}") }
			else
				{ :id => u.id, :city => u.city, :enabled => u.enabled, :name => u.name, :mobile => u.mobile, :phone => u.phone,:imgUrl => "" }
			end
		end
		
		render json: {
			message: 'Success',
			status: 200,
			count: count_driver,
			drivers: @driverslist,
			}, status: 200
  end
	
  def detail
    @driver = Driver.find(params[:id])

		@startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
		@enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')
#		@dLog = Driverlog.find_by_sql ["SELECT description from driverlogs where driver_id = ? and created_at >= ? and created_at < ?", params[:id], @startdate.to_date, @enddate.to_date + 1.day]		
		@dLog = Driverlog.find_by_sql ["SELECT ready, absent, description from driverlogs where driver_id = ? order by created_at desc limit 1 ", params[:id]]		
		
		@imgUrl = ''
		
		img = @driver.images.first rescue nil
		if !img.nil? and img.file_uid
			@imgUrl = img.file.thumb('240x240').url(:suffix => "/#{img.name}")
			@imgId = img.id
		end
		
		render json: {
			message: 'Success',
			status: 200,
			driver: @driver,
			log: @dLog,
			imageUrl: @imgUrl,
			imageId: @imgId
			}, status: 200
  end
	
  def search
		vars = request.query_parameters
		name = vars['name']
    # @driver = Driver.where(name: name)
    @driver = Driver.where("name ~* '.*#{name}.*'")
 
		if @driver.nil?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else
			
		@driverslist = @driver.map do |u|
			
			img = u.images.first rescue nil
			
			if !img.nil? and img.file_uid
				{ :id => u.id, :city => u.city, :enabled => u.enabled, :name => u.name, :mobile => u.mobile, :phone => u.phone,:imgUrl => u.images.first.file.thumb('240x240').url(:suffix => "/#{u.images.first.name}") }
			else
				{ :id => u.id, :city => u.city, :enabled => u.enabled, :name => u.name, :mobile => u.mobile, :phone => u.phone,:imgUrl => "" }
			end
		end			
			
		render json: {
			message: 'Success',
			status: 200,
			drivers: @driverslist,
			}, status: 200
		end
  end
	
  def login
		vars = request.query_parameters
		driver_id = vars['id']
		phone = vars['phone']
		
		@driver = Driver.where("id = ? AND phone = ? OR mobile = ?", driver_id, phone, phone)

		if @driver.empty?
			render json: {
			message: 'Login Error - Data Not Found',
			status: 404
			}, status: 404
		else
			@drivername = @driver[0].name
			description = "Driver " + @drivername + " berhasil login pada: " + Time.now.strftime("%d-%m-%Y %H:%M:%S %Z")
			driverloginlog = Driverloginlog.create(driver_id: driver_id, description: description, login_at: Time.now)
			render json: {
			message: 'Login Succes, log created',
			status: 200,
			drivers: @driver,
			}, status: 200
		end
		
  end
	
	def update
		inputs = params[:driver]
		@driver = Driver.find(params[:id])
		if @driver.nil?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else	
			if @driver.update_attributes(inputs)
				render json: { result: true, status: 200, message: "Update Success" }, status: 200
			else 
				render json: { result: false, status: 400, message: "Update Failed" }, status: 400
			end
		end
	end
	
	def createlogs
		inputs = params[:driverlog]
		@driverlog = Driverlog.new(inputs)
		@driver = Driver.find(params[:id])

		if @driverlog.save
			@driver.enabled = inputs[:enabled]
			@driver.save
			render json: { result: true, status: 200, message: "Log Update Success" }, status: 200
		else
			render json: { result: false, status: 400, message: "Log Update Failed" }, status: 400
		end

	end
	
	def activeInvoice
		@driver_id = params[:id]
		@lastInv = Invoice.active.where('deleted = false and driver_id = :driver_id', {:driver_id => @driver_id}).order("id desc").limit(1)
		
		@lastInvDetail = @lastInv.map do |u|
			{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :route => u.route.name, :customer_name => u.customer.name }
		end
		
		if @lastInv.blank?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else
			render json: {
			message: 'Success',
			status: 200,
			invoice: @lastInvDetail,
			}, status: 200
		end
		
	end
	
	def invoiceSJ
		@driver_id = params[:id]
		
		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		$globalDate = @date

		@invoice_id = params[:invoice_id] || ''

		if !@invoice_id.blank?
			@lastInv = Invoice.active.where("deleted = false and driver_id = ? and id = ? and id not in (select invoice_id from receipts)", @driver_id, @invoice_id).order("id DESC")
		else
			if !@date.blank?
				@lastInv = Invoice.active.where("deleted = false and driver_id = ? and date = ? and id not in (select invoice_id from receipts)", @driver_id, @date.to_date).order("id DESC")
			else
				@lastInv = Invoice.active.where("deleted = false and driver_id = ?", @driver_id).order('date DESC')
			end
		end
		
		@lastInvDetail = @lastInv.map do |u|
			{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :route => u.route.name, :customer_name => u.customer.name }
		end
		
		if @lastInv.blank?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else
			render json: {
			message: 'Success',
			status: 200,
			invoice: @lastInvDetail,
			}, status: 200
		end
		
	end

	def history
		@driver_id = params[:id]
		
		@driversactivity = Driveractivity.where('driver_id = ? and deleted = ?', params[:driver_id], false).order("id DESC")
		
		@lastInv = Invoice.active.where('deleted = false and driver_id = :driver_id AND id in (select invoice_id from driveractivities where driver_id = :driver_id AND finished = TRUE)', {:driver_id => @driver_id}).order("id desc").limit(1)
		
		@lastInvDetail = @lastInv.map do |u|
			{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :route => u.route.name, :customer_name => u.customer.name }
		end
		
		if @lastInv.blank?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else
			render json: {
			message: 'Success',
			status: 200,
			invoice: @lastInvDetail,
			}, status: 200
		end
	end

	def driverFormList
		@drivers = Driver.active.order('name')
		count_driver = @drivers.count
		
		@driverslist = @drivers.map do |u|
			
			img = u.images.first rescue nil
			
			if !img.nil? and img.file_uid
				{ :id => u.id, :city => u.city, :enabled => u.enabled, :name => u.name, :mobile => u.mobile, :phone => u.phone,:imgUrl => u.images.first.file.thumb('240x240').url(:suffix => "/#{u.images.first.name}") }
			else
				{ :id => u.id, :city => u.city, :enabled => u.enabled, :name => u.name, :mobile => u.mobile, :phone => u.phone,:imgUrl => "" }
			end
		end
		
		render json: {
			message: 'Success',
			status: 200,
			count: count_driver,
			drivers: @driverslist,
		}, status: 200
	end

	def getdriver_by_idcard
		@drivers = Driver.active.where("id_card IS NOT NULL").order('name')
		count_driver = @drivers.count
		
		@driverslist = @drivers.map do |u|
			{
				:id => u.id,
				:name => u.name,
				:address => u.address,
				:city => u.city,
				:phone => u.phone,
				:mobile => u.mobile,
				:emergency_number => u.emergency_number,
				:driver_license => u.driver_licence,
				:driver_license_expiry => u.driver_licence_expiry,
				:id_card => u.id_card,
				:id_card_expiry => u.id_card_expiry,
				:salary => u.salary,
				:jamsostek => u.min_wages,
				:start_working => u.start_working,
				:status => u.status,
				:accident => u.accident.to_i,
				:weight_loss => u.weight_loss.to_i,
				:sparepart => u.sparepart.to_i,
				:bon => u.bon.to_i,
				:saving => u.saving.to_i,
				:bank_name => u.bank_name,
				:bank_account => u.bank_account,
				:bankexpensegroup_id => u.bankexpensegroup_id,
				:origin => u.origin,
				:vendor_id => u.vendor_id,
				:is_resign => u.is_resign,
				:description => u.description
			}
		end
		
		render json: {
			message: 'Success',
			status: 200,
			count: count_driver,
			drivers: @driverslist,
		}, status: 200
	end
end
