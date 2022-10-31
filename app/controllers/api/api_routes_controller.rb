class Api::ApiRoutesController < ApplicationController
	# before_action :authenticate_user!, :only => [:test]
	
	# def test
	# end

    def get_detail_route
        route = Route.find(params[:id]) rescue nil

		if route.present?

            allowances = Allowance.where('route_id = ? and deleted = false', route.id)

            routeDetail = { 
                :id => route.id,
                :name => route.name,
                :allowances => allowances
            }

            render json: { status: 200, data: routeDetail, message: "Route & Allowances is found" }, status: 200
        
        else
            render json: { status: 400, message: "Route & Allowances not found" }, status: 400
        end
    end

    def create_route
    
		inputs = params[:route]

    	@route = Route.new(inputs)

        if @route.save

            render json: {
            status: 200,
            data: @route,
            message: 'Success Create Route',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Route',
            }, status: 400
        
        end    
    end

    def create_route_2
    
		# inputs = params[:route]

    	@route = Route.new

        @route.company_id = params[:company_id]
        @route.customer_id = params[:customer_id]
        @route.office_id = params[:office_id]
        @route.name = params[:name]
        @route.description = params[:description]
        @route.routegroup_id = params[:routegroup_id]
        @route.price_per = params[:price_per]
        @route.price_per_type = params[:price_per_type]
        @route.distance = params[:distance]

        if @route.save

            render json: {
            status: 200,
            data: @route,
            message: 'Success Create Route',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Route',
            }, status: 400
        
        end    
    end

    def create_allowance

		inputs = params[:allowance] 
 
    	@allowance = Allowance.new(inputs)
        
        if @allowance.save

            newest_route_id = Route.order('id DESC').limit(1)
            new_allowance = Allowance.find(@allowance.id)
            new_allowance.route_id = newest_route_id[0].id
            new_allowance.save

            render json: {
            status: 200,
            newest_route_id: newest_route_id,
            data: new_allowance,
            message: 'Success Create Allowance',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Allowance',
            }, status: 400
        
        end    
    end

    def create_allowance_2
 
    	@allowance = Allowance.new

        @allowance.route_id = params[:route_id]
        @allowance.vehiclegroup_id = params[:vehiclegroup_id]
        @allowance.driver_trip = params[:driver_trip]
        @allowance.gas_trip = params[:gas_trip]
        @allowance.misc_allowance = params[:misc_allowance]
        @allowance.helper_trip = params[:helper_trip]
        @allowance.train_trip = params[:train_trip]
 
        if @allowance.save

            render json: {
            status: 200,
            data: @allowance,
            message: 'Success Create Allowance',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Allowance',
            }, status: 400
        
        end    
    end

end