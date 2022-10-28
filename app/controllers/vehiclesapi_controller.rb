class VehiclesapiController < ApplicationController
	
	def index
		@vehicles = Vehicle.order("generic, current_id").where("deleted = false AND current_id NOT LIKE '%BOX%' AND current_id NOT LIKE '%Flatdeck%' AND current_id NOT LIKE '%Ekor%' ")
		count_vehicle = @vehicles.count
		
		@vehicleslist = @vehicles.map do |u|
			
			img = u.images.first rescue nil
			
			if !img.nil? and img.file_uid
				{ :id => u.id, :year_made => u.year_made, :enabled => u.enabled, :vehicletype => u.vehicle_type, :current_id => u.current_id, :imgUrl => u.images.first.file.thumb('240x240').url(:suffix => "/#{u.images.first.name}") }
			else
				{ :id => u.id, :year_made => u.year_made, :enabled => u.enabled, :vehicletype => u.vehicle_type, :current_id => u.current_id, :imgUrl => "" }
			end
		end
 
		render json: {
			message: 'Success',
			status: 200,
			count: count_vehicle,
			vehicles: @vehicleslist,
			}, status: 200
  end
	
	def detail
    @vehicles = Vehicle.find(params[:id])
		@vehiclelog = Vehiclelog.where(vehicle_id: params[:id]).order("id DESC").limit(1)
		
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		$globalDate = @date
		
		@invoices = Invoice.active.where('date = :date and deleted = false and vehicle_id = :vehicle_id', {:date => @date.to_date, :vehicle_id => params[:id]}).order("id DESC")
		
		@invoicelist = @invoices.map do |u|
			{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_id => u.driver_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :driver_mobile => u.driver.mobile, :route => u.route.name, :customer_name => u.customer.name }
		end
		
		@imgUrl = ''
		
		img = @vehicles.images.first rescue nil
		if !img.nil? and img.file_uid
			@imgUrl = img.file.thumb('240x240').url(:suffix => "/#{img.name}")
			@imgId = img.id
		end
		
		render json: {
			message: 'Success',
			status: 200,
			vehicles: @vehicles,
			log: @vehiclelog,
			invoiceActive: @invoicelist,
			imageUrl: @imgUrl,
			imageId: @imgId
			}, status: 200
  end
	
	def update
		inputs = params[:vehicle]
		@vehicle = Vehicle.find(params[:id])
		if @vehicle.nil?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else	
			if @vehicle.update_attributes(inputs)
				render json: { result: true, status: 200, message: "Update Vehicle Success" }, status: 200
			else 
				render json: { result: false, status: 400, message: "Update Vehicle Failed" }, status: 400
			end
		end
	end
	
	def search
		vars = request.query_parameters
		vehicle_id = vars['id'] 
		
		@vehicles = Vehicle.where(current_id: vehicle_id) 
		
		@vehicleslist = @vehicles.map do |u|
			
			img = u.images.first rescue nil
			
			if !img.nil? and img.file_uid
				{ :id => u.id, :year_made => u.year_made, :enabled => u.enabled, :machine_serial => u.machine_serial, :vehicletype => u.vehicle_type, :current_id => u.current_id, :previous_id => u.previous_id, :imgUrl => u.images.first.file.thumb('240x240').url(:suffix => "/#{u.images.first.name}"), :logs => u.vehiclelogs.active }
			else
				{ :id => u.id, :year_made => u.year_made, :enabled => u.enabled, :machine_serial => u.machine_serial, :vehicletype => u.vehicle_type, :current_id => u.current_id, :previous_id => u.previous_id, :imgUrl => "", :logs => u.vehiclelogs.active  }
			end
		end
		
		if @vehicles.empty?
			render json: {
			message: 'Error - Data Not Found',
			status: 404
			}, status: 404
		else
			render json: {
			message: 'Success',
			status: 200,
			vehicles: @vehicleslist,
			}, status: 200
		end
		
	end
	
	def createlogs
		inputs = params[:vehiclelog]
    @vehiclelog = Vehiclelog.new(inputs)
    @vehicle = Vehicle.find(inputs[:vehicle_id])

		if @vehiclelog.save
			@vehicle.enabled = inputs[:enabled]
			@vehicle.save
			render json: { result: true, status: 200, message: "Log Update Success" }, status: 200
		else
			render json: { result: false, status: 400, message: "Log Update Failed" }, status: 400
		end
 
		
	end
	
	def vehicleFormList
		@vehicles = Vehicle.active.order("generic, current_id").where("deleted = false AND current_id NOT LIKE '%BOX%' AND current_id NOT LIKE '%Flatdeck%' AND current_id NOT LIKE '%Ekor%' ")
		count_vehicle = @vehicles.count
		
		@vehicleslist = @vehicles.map do |u|
			
			img = u.images.first rescue nil
			
			if !img.nil? and img.file_uid
				{ :id => u.id, :year_made => u.year_made, :enabled => u.enabled, :vehicletype => u.vehicle_type, :current_id => u.current_id, :imgUrl => u.images.first.file.thumb('240x240').url(:suffix => "/#{u.images.first.name}") }
			else
				{ :id => u.id, :year_made => u.year_made, :enabled => u.enabled, :vehicletype => u.vehicle_type, :current_id => u.current_id, :imgUrl => "" }
			end
		end
 
		render json: {
			message: 'Success',
			status: 200,
			count: count_vehicle,
			vehicles: @vehicleslist,
			}, status: 200
  end
	def current_bkk
		# bkk = Invoice.active.order("id desc").limit(7).map do |invoice|
		# 	driver = invoice.driver
		# 	route = invoice.route
		# 	{
		# 		id: invoice.id,
		# 		customer: (invoice.customer.name rescue nil),
		# 		routes: (route.name rescue nil)+" "+(route.routegroup.name rescue nil),
		# 		driver: (driver.name),
		# 		driver_phone: (driver.mobile),
		# 		quantity: invoice.quantity,
		# 		date: invoice.date,
		# 		need_helper: invoice.need_helper
		# 	}
		# end
		# render json: bkk
		vehicles = Vehicle.active.where("gps_number is not null").map do |vehicle|
			invoices = Invoice.active.where(vehicle_id: vehicle.id).where(date: Date.today).map do |invoice|
				driver = invoice.driver
				route = invoice.route
				{
					id: invoice.id,
					customer: (invoice.customer.name rescue nil),
					routes: (route.name rescue nil)+" "+(route.routegroup.name rescue nil),
					driver: (driver.name),
					driver_phone: (driver.mobile),
					quantity: invoice.quantity,
					date: invoice.date,
					need_helper: invoice.need_helper
				}
			end
			{
				current_id: vehicle.current_id,
				device_id: vehicle.gps_number,
				invoice: invoices
			}
		end
		render json: vehicles
	end

	def vehicle_invoice_list
		if params[:deviceId].present?
			vehicle = Vehicle.active.where(gps_number: params[:deviceId]).first
			if vehicle.present?
				invoices = Invoice.active.where(vehicle_id: vehicle.id).order("id desc").limit(7).map do |invoice|
					driver = invoice.driver
					route = invoice.route
					{
						id: invoice.id,
						customer: (invoice.customer.name rescue nil),
						routes: (route.name rescue nil)+" "+(route.routegroup.name rescue nil),
						driver: (driver.name),
						driver_phone: (driver.mobile),
						quantity: invoice.quantity,
						date: invoice.date,
						need_helper: invoice.need_helper
					}
				end
	
				render json: {
					vehicle: vehicle,
					invoices: invoices
				}
			end
			return false
		end
		render json: {}
	end
end
