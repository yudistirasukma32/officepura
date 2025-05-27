class RoutelocationsController < ApplicationController
	
	def new
		@routelocation = Routelocation.new
		@route = Route.find(params[:route_id])
    @customer = Customer.find(@route.customer_id)
	end
	
	def create
		inputs = params[:routelocation]
		@routelocation = Routelocation.new(inputs)
		@route = Route.find(inputs[:route_id])
		if @routelocation.save
      redirect_to(edit_route_url(@route), :notice => 'Data Lokasi berhasil ditambah.')
    else
      to_flash(@route)
      render :action => "new"
    end
	end
	
	def edit
    @route = Route.find(params[:route_id])
    @customer = Customer.find(@route.customer_id)
		@routeloc = Routelocation.where("route_id = ?", params[:route_id]).order("id DESC").limit(1)
		@routelocation = Routelocation.where("route_id = ?", params[:route_id]).order("id DESC").find(@routeloc.first.id)
	end
	
  def update
    inputs = params[:routelocation]
    @routelocation = Routelocation.find(params[:id])
		@route = Route.find(inputs[:route_id])

    if @routelocation.update_attributes(inputs)
      @routelocation.save
      redirect_to(edit_route_url(@route), :notice => 'Data Lokasi berhasil disimpan.')
    else
      to_flash(@route)
      render :action => "edit"
    end
  end
	
	def getDataApi
		@routelocation = Routelocation.where(route_id: params[:route_id]).order("id DESC").limit(1)
		render json: {
			message: 'Success',
			status: 200,
			routelocation: @routelocation,
			}, status: 200
	end	
	
	def getAllDataApi
		@routelocation = Routelocation.order("id DESC")
		render json: {
			message: 'Success',
			status: 200,
			routelocation: @routelocation,
			}, status: 200
	end	

  def createApi
		inputs = params[:routelocation]
		@routelocation = Routelocation.new(inputs)
		@route = Route.find(inputs[:route_id])

		if @routelocation.save
			render json: { result: true, status: 200, message: "Route Location Update Success" }, status: 200
		else
			render json: { result: false, status: 400, message: "Route Location Update Failed" }, status: 400
		end
  end
	
	def create
		inputs = params[:routelocation]
		@routelocation = Routelocation.new(inputs)
		@route = Route.find(inputs[:route_id])

		if @routelocation.save
		 redirect_to(edit_route_url(@route), :notice => 'Data Lokasi Jurusan sukses di tambah.')
		end
		
	end

	def checkDistance

		require "uri"
		require "net/http"
	
		lng_start = params[:longitude_start]
		lat_start = params[:latitude_start]
	
		lng_end = params[:longitude_end]
		lat_end = params[:latitude_end]
		
		# api_key = "AIzaSyDwuoQZDV6IQ7fpPGvmgBqnueUSu6uB4qU"
		api_key = "AIzaSyAseVu713ju2rF1ryj_KjGMoP5LkbrtJQA"
	 
		url_string = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=#{lat_start},#{lng_start}&destinations=#{lat_end},#{lng_end}&mode=driving&units=metric&key=#{api_key}"
		url = URI.parse(url_string) # Use `URI.parse` instead of `URI()`
		
		https = Net::HTTP.new(url.host, url.port)
		https.read_timeout = 3600
		https.use_ssl = true
		https.verify_mode = OpenSSL::SSL::VERIFY_NONE

		# request = Net::HTTP::Get.new(url)
		request = Net::HTTP::Get.new(url.request_uri) # Use `request_uri` instead of `url`
		response = https.request(request)
		# puts response.read_body
		# data = JSON.parse(response.read_body)
		data = JSON.parse(response.body) # Use `.body` instead of `.read_body` for compatibility

		if data["status"] == "OK"
		  distance_value = data["rows"][0]["elements"][0]["distance"]["value"] # Distance in meters
		  distance_km = distance_value / 1000.0  # Convert meters to kilometers
		  destination_addresses = data["destination_addresses"][0]
		  origin_addresses = data["origin_addresses"][0]
	
		#   puts "Distance: #{distance_km} km"
			render json: {status: 200, success: true, origin_addresses: origin_addresses, destination_addresses: destination_addresses, distance_km: distance_km.ceil, distance_value: distance_value}
		else
		#   puts "Error: #{data['status']}"
			  render json: {success: true, distance_km: 0, distance_value: 0}
		end
	
	  end
	
end
