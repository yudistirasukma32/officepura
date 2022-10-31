class Api::ApiCustomersController < ApplicationController
	# before_action :authenticate_user!, :only => [:test]
	
	# def test
	# end

    def get_all_customers
        customers = Customer.active.order(:name)
        if customers.present?
            
			customers = customers.map do |c|
				{ 
                    :id => c.id,  
				    :name => c.name
		    	}
			end

			render json: { status: 200, data: customers, message: "Customers found" }, status: 200
		else
			render json: { status: 400, message: "Customers not found" }, status: 400
		end
    end

    def get_detail_customer
        customer = Customer.find(params[:id]) rescue nil

		if customer.present?

            customerDetail = { 
                :id => customer.id,
                :customer_name => customer.name,
                :wholesale_price => customer.wholesale_price
            }

            render json: { status: 200, data: customerDetail, message: "customer is found" }, status: 200
        
        else
            render json: { status: 400, message: "Customers not found" }, status: 400
        end
    end

end