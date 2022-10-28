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
	
end
