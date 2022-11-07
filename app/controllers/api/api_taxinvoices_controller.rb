class Api::ApiTaxinvoicesController < ApplicationController
	# before_action :authenticate_user!, :only => [:test]
	
	# def test
	# end

    def get_detail_taxinvoice
        taxinvoice = Taxinvoice.find(params[:id]) rescue nil

		if taxinvoice.present?

            taxinvoiceDetail = { 
                :id => taxinvoice.id,
                :customer_id => custome.id
            }

            render json: { status: 200, data: taxinvoiceDetail, message: "taxinvoice is found" }, status: 200
        
        else
            render json: { status: 400, message: "taxinvoices not found" }, status: 400
        end
    end

    def create_taxinvoice
        # inputs = params[""]
    
		inputs = params[:taxinvoices]

    	@taxinvoices = Taxinvoice.new(inputs)

        if @taxinvoices.save

            render json: {
            status: 200,
            data: @taxinvoices,
            message: 'Success Create Taxinvoice',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Taxinvoice',
            }, status: 400
        
        end    
    end

    def create_taxinvoice_2
    
		# inputs = params[:route]

    	@taxinvoices = Taxinvoice.new

        @taxinvoices.customer_id = params[:customer_id]
        @taxinvoices.date = params[:date]
        @taxinvoices.long_id = params[:long_id]
        @taxinvoices.period_start = params[:period_start]
        @taxinvoices.period_end = params[:period_end]
        @taxinvoices.generic = params[:generic]
        @taxinvoices.gst_tax = params[:gst_tax]
        @taxinvoices.gst_percentage = params[:gst_percentage]
        @taxinvoices.price_tax = params[:price_tax]
        @taxinvoices.total = params[:total]

        if @taxinvoices.save

            render json: {
            status: 200,
            data: @taxinvoices,
            message: 'Success Create Route',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Route',
            }, status: 400
        
        end    
    end

    def create_taxinvoice_taxgenericitem
        # inputs = params[""]
    
		inputs = params[:taxgenericitems]

        vehicle = inputs[:vehicle_id]

        vehicles = Vehicle.where("current_id LIKE ?", "%#{vehicle}%")

        if vehicles.any?
        
            vehicle_id = vehicles[0].id

        else
            
            vehicle_id = 1

        end
        
    	@taxgenericitem = Taxgenericitem.new(inputs)
        @taxgenericitem.vehicle_id = vehicle_id

        if @taxgenericitem.save

            render json: {
            status: 200,
            data: @taxgenericitem,
            message: 'Success Create Taxinvoiceitems',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Taxinvoiceitems',
            }, status: 400
        
        end    
    end

    def create_taxinvoice_taxgenericitem_2

        #check vehicle first
        vehicle = inputs[:vehicle_id]
        vehicles = Vehicle.where("current_id LIKE ?", "%#{vehicle}%")
        if vehicles.any?
            vehicle_id = vehicles[0].id
        else
            vehicle_id = 1
        end
        
    	@taxgenericitem = Taxgenericitem.new

        @taxgenericitem.vehicle_id = vehicle_id
        @taxgenericitem.date = params[:date]
        @taxgenericitem.description = params[:description]
        @taxgenericitem.sku_id = params[:sku_id]
        @taxgenericitem.vehicle_id = vehicle_id
        @taxgenericitem.taxinvoice_id = params[:taxinvoice_id]
        @taxgenericitem.weight_gross = params[:weight_gross]
        @taxgenericitem.weight_net = params[:weight_net]
        @taxgenericitem.price_per = params[:price_per]
        @taxgenericitem.total = params[:total]
  
        if @taxgenericitem.save

            render json: {
            status: 200,
            data: @taxgenericitem,
            message: 'Success Create Taxinvoiceitems',
            }, status: 200
            
        else
            
            render json: {
            status: 400,
            message: 'Failed Create Taxinvoiceitems',
            }, status: 400
        
        end    
    end

end