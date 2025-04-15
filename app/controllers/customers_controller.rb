class CustomersController < ApplicationController
	include ApplicationHelper
	layout "application"
  protect_from_forgery :except => [:transfer]
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "customers"
    @attachments_category = ["KTP", "NPWP", "NIB", "SIUP", "AKTA PERUSAHAAN", "SURAT PENAWARAN", "LAINNYA"]
  end

  def set_role
    @user_role = 'Admin Marketing, Marketing, Admin Keuangan, Master Jurusan, User Jurusan, Admin Jurusan, Lihat Pelanggan'
  end

  def index
    role = cek_roles @user_role
    if role
      @customers = Customer.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end

  end

  def new
    @process = 'new'
    @customer = Customer.new
    @customer.enabled = true
    @customer.wholesale_price = @customer.wholesale_price.to_i 
  end

  def edit
    @process = 'edit'
    @customer = Customer.find(params[:id])
    @routes = @customer.routes.where('deleted = false').order(:name)
    @contracts = @customer.contracts.where('deleted = false').order(:date_start)
    @customer.wholesale_price = @customer.wholesale_price.to_i
  end

  def create
    inputs = params[:customer]
    @customer = Customer.new(inputs)

    if inputs[:price_tax] == 'Yes'
      @customer.price_tax = true
    else
      @customer.price_tax = false
    end

    if @customer.save
      redirect_to(edit_customer_url(@customer), :notice => 'Data Pelanggan sukses di tambah.')
    else
      to_flash(@customer)
      render :action => "new"
    end
  end

  def update
    inputs = params[:customer]
    @customer = Customer.find(params[:id])

    if @customer.update_attributes(inputs)

      if inputs[:price_tax] == 'Yes'
        @customer.price_tax = true
      else
        @customer.price_tax = false
      end

      if inputs[:is_weightlost] == 'Yes'
        @customer.is_weightlost = true
      else
        @customer.is_weightlost = false
      end

      if inputs[:is_showqty_loaded] == 'Yes'
        @customer.is_showqty_loaded = true
      else
        @customer.is_showqty_loaded = false
      end

      if inputs[:is_showqty_unloaded] == 'Yes'
        @customer.is_showqty_unloaded = true
      else
        @customer.is_showqty_unloaded = false
      end

      if inputs[:is_rounded] == 'Yes'
        @customer.is_rounded = true
      else
        @customer.is_rounded = false
      end

      @customer.save
      redirect_to(edit_customer_url(@customer), :notice => 'Data Pelanggan sukses di simpan.')
    else
      to_flash(@customer)
      render :action => "edit"
    end
  end

  def addroute
    redirect_to new_route_path(params[:id])
  end

  def addcontract
    redirect_to new_contract_path(params[:id])
  end

  def destroy
    @customer = Customer.find(params[:id])
    @customer.deleted = true
    @customer.save
    redirect_to(customers_url)
  end

  def enable
    @customer = Customer.find(params[:id])
    @customer.update_attributes(:enabled => true)
    redirect_to(customers_url)
  end

  def disable
    @customer = Customer.find(params[:id])
    @customer.update_attributes(:enabled => false)
    redirect_to(customers_url)
  end

  def clone

    @customer = Customer.find(params[:id])

    require "uri"
		require "net/http"
		require "openssl"
		require 'json'

    url = URI("https://office.puratrans.com/api_customers/get_all_customers")
    # url = URI("http://localhost:3001/api_customers/get_all_customers")

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
		@response = response.read_body

		if JSON(@response)['status'] == 404

		@customerlist = ''

		else

		@customerlist = JSON(@response)['data']

		end

  end

  def transfer

    # @customer = Customer.find(params[:id])
    # customer_destinaton = params[:customer_id]

    # require "uri"
		# require "net/http"
		# require "openssl"
		# require 'json'

    # customerRoutes = Route.where('customer_id = ?', @customer.id)

    # @checkAllowance = []

    # if customerRoutes.present?

    #   customerRoutes = customerRoutes.map do |r|

    #     url = URI("https://office.puratrans.com/api_routes/create_route")

    #     http = Net::HTTP.new(url.host, url.port)
    #     http.use_ssl = true
    #     http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #     request = Net::HTTP::Post.new(url.request_uri)
    #     request["Content-Type"] = "application/json"
    #     request.body = JSON.dump({
    #       "route": {
    #         "company_id": 1,
    #         "customer_id": customer_destinaton,
    #         "office_id": 6,
    #         "name": r.name,
    #         "description": r.description,
    #         "routegroup_id": r.routegroup_id,
    #         "price_per": r.price_per,
    #         "price_per_type": r.price_per_type,
    #         "distance": r.distance
    #       }
    #     })

    #     response = http.request(request)
    #     @response = response.read_body

    #     if JSON(@response)['status'] == 404

    #       render json: { status: 400, message: "Customers not found" }, status: 400

    #     else

    #       @allowances = Allowance.where('route_id = ? AND vehiclegroup_id in (1,2,3)', r.id)

    #       if @allowances.present?

    #         allowances_all = @allowances.map do |al|

    #           url = URI("https://office.puratrans.com/api_routes/create_allowance")
    
    #           http = Net::HTTP.new(url.host, url.port)
    #           http.use_ssl = true
    #           http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    #           request = Net::HTTP::Post.new(url.request_uri)
    #           request["Content-Type"] = "application/json"

    #           request.body = JSON.dump({
    #             "allowance": {
    #               "vehiclegroup_id": al.vehiclegroup_id,
    #               "driver_trip": al.driver_trip,
    #               "gas_trip": al.gas_trip,
    #               "misc_allowance": al.misc_allowance,
    #               "helper_trip": al.helper_trip,
    #               "train_trip": al.train_trip,
    #               "wholesale_trip": 0
    #             }
    #           })

    #           response = http.request(request)
    #           response2 = response.read_body

    #         end

    #       end

    #     end

    #   end

    #   render json: {
    #     status: 200,
    #     message: 'Success Create Route and Allowance',
    #   }, status: 200

    # else
    # end

  end

end
