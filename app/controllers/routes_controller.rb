class RoutesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
    @where = "routes"
    @price_per_types = ["KG", "LITER", "BORONGAN"]
    @transporttypes = ["TRUK", "ISOTANK", "KERETA", "KAPAL (TOL LAUT)"]
  end

  def index
    @routes = Route.active.where('office_id is not null').order('name ASC')
    
    @office_id = params[:office_id]

    @offices = Office.active.order('id asc')
    if @office_id.present? and @office_id != "all"
      @routes = @routes.where("office_id = ?", @office_id)
    end 
  end

  def addnew
    @route = Route.new
    respond_to :html
  end

  def new
    @route = Route.new
    @customer = Customer.find(params[:format])
    @route.customer_id = @customer.id
    @route.ferry_fee = @route.ferry_fee.to_i
    @route.tol_fee = @route.tol_fee.to_i
    @route.bonus = @route.bonus.to_i
    @route.enabled = true
    # respond_to :html
  end

  def edit
    @route = Route.find(params[:id])
    @customer = Customer.find(@route.customer_id)
    @route.ferry_fee = @route.ferry_fee.to_i
    @route.tol_fee = @route.tol_fee.to_i
    @route.bonus = @route.bonus.to_i

    @routeloc = Routelocation.where("route_id = ?", params[:id]).order("id DESC").limit(1)
		
		if @routeloc.first.nil?
			@routelocation = Routelocation.new
			@routelocation.route_id = @route.id
			@routelocation.customer_id = @customer.id
			@routelocation.save
		else
			@routelocation = Routelocation.where("route_id = ?", params[:id]).order("id DESC").find(@routeloc.first.id)
		end

    @vehiclegroups = Vehiclegroup.all
    @vehiclegroups.each do |g|
      if g.allowances.where(:route_id => @route.id).first.nil?
        allowance = Allowance.new
        allowance.route_id = @route.id
        allowance.vehiclegroup_id = g.id
        allowance.save
      end
    end
  end

  def create
    inputs = params[:route]
    @route = Route.new(inputs)
    @route.enabled = true
    @route.price_per = inputs[:price_per].delete('.').gsub(",",".") || 0

    if @route.save
      redirect_to(edit_route_url(@route), :notice => 'Data Jurusan sukses di tambah.')
    else
      to_flash(@route)
      render :action => "new"
    end
  end

  def update
    inputs = params[:route]
    @route = Route.find(params[:id])
    oldcustomer = @route.customer_id
    # needupdate = false

    #if @route.price_per.to_i != inputs[:price_per].to_i
    #  needupdate = true
    #end

    if @route.update_attributes(inputs)
      @route.price_per = inputs[:price_per].delete('.').gsub(",",".") || 0
      @route.save

      if oldcustomer != @route.customer_id
        invoices = Invoice.where(:customer_id => oldcustomer, :route_id => @route.id)
        if invoices.any?
          invoices.each do |invoice|
            invoice.customer_id = @route.customer_id
            invoice.save

            invoice.taxinvoiceitems.where(:taxinvoice_id => nil).each do |taxinvoiceitem|
              taxinvoiceitem.customer_id = @route.customer_id
              taxinvoiceitem.save
            end
          end
        end
      end

      #if needupdate == true
      #  invoices = Invoice.where(:route_id => @route.id, :deleted => false)
      #
      #  if invoices.any?
      #    invoices.each do |invoice|
      #       invoice.price_per = @route.price_per
      #       invoice.save
      #     end
      #   end
      # end
      
      redirect_to(edit_route_url(@route, :operational => true), :notice => 'Data Jurusan sukses disimpan.')
    else
      to_flash(@route)
      render :action => "edit"
    end
  end

  def destroy
    @route = Route.find(params[:id])
    customer_id = @route.customer_id
    @route.destroy
    redirect_to edit_customer_url(customer_id)+'/#2'
  end  
  
  def enable
    @route = Route.find(params[:id])
    @route.update_attributes(:enabled => true)
    redirect_to (routes_url)
  end
  
  def disable
    @route = Route.find(params[:id])
    @route.update_attributes(:enabled => false)
    redirect_to (routes_url)
  end
end