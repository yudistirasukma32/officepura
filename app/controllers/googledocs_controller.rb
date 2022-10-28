class GoogledocsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section
  protect_from_forgery :authenticate_user! => [:index]

  def set_section
    @section = "masters"
  end

  def index

    if !params[:gkey].blank?
      s = Google.new(params[:gkey],"sinata@mydevteam.com.au","sinata01") rescue nil
    end

    #begin
    if !s.nil?
      # s.default_sheet = 'Kas Bank'
      # 5.upto(s.last_row) do |line|
      #  group = Bankexpensegroup.new
      #  group.name = s.cell(line,"A")
      #  group.save
      # end

      s.default_sheet = 'Pelanggan'
      5.upto(s.last_row) do |line|
        customer = Customer.new
        customer.name = s.cell(line,"A")
        customer.address = s.cell(line,"B")
        customer.city = s.cell(line,"C")
        customer.contact = s.cell(line,"D")
        customer.phone = s.cell(line,"E")
        customer.mobile = s.cell(line,"F")
        customer.save
      end

      s.default_sheet = 'Jurusan'
      6.upto(s.last_row) do |line|
        route = Route.new
        customer = Customer.find_by_name(s.cell(line,"A")) rescue nil
        route.customer_id = customer.id if !customer.nil?
        route.name = s.cell(line,"B")
        route.routegroup_id = Routegroup.find_by_name(s.cell(line,"C")).id
        route.item_type = s.cell(line,"D")
        route.distance = s.cell(line,"E")
        route.price_per = s.cell(line,"F")
        route.price_per_type = s.cell(line,"F") || s.cell(line,"I")
        route.description = s.cell(line,"J")
        route.ferry_fee = s.cell(line,"K")
        route.tol_fee = s.cell(line,"L")
        route.bonus = s.cell(line,"M")
        route.save

        allowance = Allowance.new
        allowance.vehiclegroup_id = Vehiclegroup.find_by_name("SIL 6").id
        allowance.route_id = route.id
        allowance.driver_trip = s.cell(line,"N") if !s.cell(line,"N").blank? || 0
        allowance.gas_trip = s.cell(line,"O") if !s.cell(line,"O").blank? || 0
        allowance.misc_allowance = s.cell(line,"P") if !s.cell(line,"P").blank? || 0
        allowance.save

        allowance = Allowance.new
        allowance.vehiclegroup_id = Vehiclegroup.find_by_name("SIL 8").id
        allowance.route_id = route.id
        allowance.driver_trip = s.cell(line,"Q") if !s.cell(line,"Q").blank? || 0
        allowance.gas_trip = s.cell(line,"R") if !s.cell(line,"R").blank? || 0
        allowance.misc_allowance = s.cell(line,"S") if !s.cell(line,"S").blank? || 0
        allowance.save

        allowance = Allowance.new
        allowance.vehiclegroup_id = Vehiclegroup.find_by_name("LOKAL").id
        allowance.route_id = route.id
        allowance.driver_trip = s.cell(line,"T") if !s.cell(line,"T").blank? || 0
        allowance.gas_trip = s.cell(line,"U") if !s.cell(line,"U").blank? || 0
        allowance.misc_allowance = s.cell(line,"V") if !s.cell(line,"V").blank? || 0
        allowance.save
      end

      # s.default_sheet = 'Kendaraan'
      # 5.upto(s.last_row) do |line|
      #   vehicle = Vehicle.new
      #   vehicle.current_id = s.cell(line,"A")
      #   vehicle.previous_id = s.cell(line,"B")
      #   vehicle.id_expiry = s.cell(line,"C").to_date
      #   vehicle.year_made = s.cell(line,"D").to_i.to_s
      #   vehicle.vehicle_type = s.cell(line,"E")
      #   vehicle.registration = s.cell(line,"F")
      #   vehicle.vehiclegroup_id = Vehiclegroup.find_by_name(s.cell(line,"G")).id rescue nil || 0
      #   vehicle.tire_size = s.cell(line,"H").to_i.to_s
      #   vehicle.tank_capacity = s.cell(line,"L")
      #   vehicle.save
      # end

      # s.default_sheet = 'Sopir'
      # 5.upto(s.last_row) do |line|
      #   driver = Driver.new
      #   driver.name = s.cell(line,"A")
      #   driver.address = s.cell(line,"B")
      #   driver.city = s.cell(line,"C")
      #   driver.phone = s.cell(line,"D")
      #   driver.mobile = s.cell(line,"E")
      #   driver.salary = s.cell(line,"J")
      #   driver.status = s.cell(line,"M")
      #   driver.save
      # end

      # s.default_sheet = 'Barang'
      # 5.upto(s.last_row) do |line|
      #   product = Product.new
      #   product.name = s.cell(line,"A")
      #   product.unit_name = s.cell(line,"D")
      #   product.stock = s.cell(line,"E")
      #   product.unit_price = s.cell(line,"F")
      #   product.description = s.cell(line,"K")
      #   product.status = 'Baru'
      #   product.warehouse_id = 1
      #   productgroup = Productgroup.find_by_name(s.cell(line,"L")) rescue nil
      #   product.productgroup_id = productgroup.id if !productgroup.nil?
      #   product.save
      # end
    end

    respond_to :html
  end

end
