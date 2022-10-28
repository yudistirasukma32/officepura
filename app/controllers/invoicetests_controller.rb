class InvoicetestsController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:get_routes, :get_allowances, :get_vehicles, :get_vehicle, :get_vehiclegroupid]
  protect_from_forgery :except => [:add, :updateinvoice]
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "invoicetests"
  end

  def form_event
    @section = "logs"
    @month = params[:month]
    @month = "%02d" % Date.today.month.to_s if @month.nil?
    @year = params[:year]
    @year = Date.today.year if @year.nil?
    # @newDate = Date.new(@year.to_i, @month.to_i)
    # @end_of_month = @newDate.at_end_of_month.day

    @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
    @vehicle_id = @vehicle.id if @vehicle

    @driver = Driver.find(params[:driver_id]) rescue nil
    @driver_id = @driver.id if @driver

    # @invoices = Invoice.active.where("to_char(date, 'mm-yyyy')='#{@month}-#{@year}' AND id IN (SELECT invoice_id FROM receipts WHERE deleted=False)")
    # @invoices = @vehicle.invoices.active.where("to_char(date, 'mm-yyyy')='#{@month}-#{@year}' AND id IN (SELECT invoice_id FROM receipts WHERE deleted=False)") if @vehicle && !@driver
    # @invoice = @driver.invoices.active.where("to_char(date, 'mm-yyyy')='#{@month}-#{@year}' AND id IN (SELECT invoice_id FROM receipts WHERE deleted=False)") if @driver && !@vehicle

    if @vehicle && !@driver
      @invoices = Invoice.find_by_sql("SELECT a.*, b.current_id, c.name as route_name, d.name as driver_name  
                                       FROM invoices a 
                                       INNER JOIN vehicles b ON b.id=a.vehicle_id
                                       INNER JOIN routes c ON c.id=a.route_id
                                       INNER JOIN drivers d ON d.id=a.driver_id  
                                       WHERE a.deleted=False AND 
                                             to_char(a.date, 'mm-yyyy')='#{@month}-#{@year}' AND 
                                             a.id IN (SELECT invoice_id FROM receipts WHERE deleted=False) AND
                                             a.vehicle_id=#{@vehicle_id}
                                       ORDER BY a.date")
    elsif @driver && !@vehicle
      @invoices = Invoice.find_by_sql("SELECT a.*, b.current_id, c.name as route_name, d.name as driver_name  
                                       FROM invoices a 
                                       INNER JOIN vehicles b ON b.id=a.vehicle_id
                                       INNER JOIN routes c ON c.id=a.route_id
                                       INNER JOIN drivers d ON d.id=a.driver_id  
                                       WHERE a.deleted=False AND 
                                             to_char(a.date, 'mm-yyyy')='#{@month}-#{@year}' AND 
                                             a.id IN (SELECT invoice_id FROM receipts WHERE deleted=False) AND
                                             a.driver_id=#{@driver_id}
                                       ORDER BY a.date")
    elsif @vehicle && @driver
      @invoices = Invoice.find_by_sql("SELECT a.*, b.current_id, c.name as route_name, d.name as driver_name  
                                       FROM invoices a 
                                       INNER JOIN vehicles b ON b.id=a.vehicle_id
                                       INNER JOIN routes c ON c.id=a.route_id
                                       INNER JOIN drivers d ON d.id=a.driver_id  
                                       WHERE a.deleted=False AND 
                                             to_char(a.date, 'mm-yyyy')='#{@month}-#{@year}' AND 
                                             a.id IN (SELECT invoice_id FROM receipts WHERE deleted=False) AND
                                             a.vehicle_id=#{@vehicle_id} AND
                                             a.driver_id=#{@driver_id}
                                       ORDER BY a.date")
    else
      @invoices = Invoice.find_by_sql("SELECT a.*, b.current_id, c.name as route_name, d.name as driver_name  
                                       FROM invoices a 
                                       INNER JOIN vehicles b ON b.id=a.vehicle_id
                                       INNER JOIN routes c ON c.id=a.route_id
                                       INNER JOIN drivers d ON d.id=a.driver_id  
                                       WHERE a.deleted=False AND 
                                             to_char(a.date, 'mm-yyyy')='#{@month}-#{@year}' AND 
                                             a.id IN (SELECT invoice_id FROM receipts WHERE deleted=False)
                                       ORDER BY a.date")
    end
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @invoices = Invoice.where("date = ?", @date.to_date).order(:id)
    respond_to :html
  end

  def new
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.new
    @invoice.office_id = current_user.office_id rescue nil || 1 
    @iseditable = true
    @invoice.enabled = true
    @invoice.date = Date.today
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @gascost = @invoice.gas_cost.to_i 
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0 if @invoice.gas_cost.nil?
    @iseditable = false
  end

  def step2
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.find(params[:id])
    respond_to :html
  end

  def confirmation
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:invoice]
    slug_currency(inputs)

    @invoice = Invoice.new

    @invoice_exist = Invoice.where(:route_id => inputs[:route_id], :vehicle_id => inputs[:vehicle_id], :date => inputs[:date].to_date, :deleted => false, :invoice_id => nil).first()

    if @invoice_exist.nil?
      @invoice.update_attributes(inputs)
    
      gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance = quantity = total = 0

      @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
      @invoice.gas_cost = @gascost

      quantity = inputs[:quantity].to_i if inputs[:quantity]
      @invoice.quantity = quantity

      @vehicle = Vehicle.find(inputs[:vehicle_id]) rescue nil
      @invoice.vehicle_id = @vehicle.id

      vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
      @invoice.vehiclegroup_id = vehiclegroup_id

      @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false

      @allowances = Allowance.where(:route_id => inputs[:route_id], :vehiclegroup_id => vehiclegroup_id, :deleted => false).first

      if !@allowances.nil?
        @route = Route.find(inputs[:route_id])

        driver_allowance = quantity * @allowances.driver_trip
        @invoice.driver_allowance = driver_allowance

        if @invoice.need_helper
          helper_allowance = quantity * @allowances.helper_trip
        else
          helper_allowance = 0
        end
        @invoice.helper_allowance = helper_allowance

        misc_allowance = quantity * @allowances.misc_allowance
        @invoice.misc_allowance = misc_allowance
        
        gas_litre = quantity * @allowances.gas_trip
        @invoice.gas_litre = gas_litre
        @invoice.gas_start = gas_litre
        
        gas_allowance = gas_litre * @gascost
        @invoice.gas_allowance = gas_allowance

        ferry_fee = @route.ferry_fee
        @invoice.ferry_fee = ferry_fee

        tol_fee = quantity * @route.tol_fee
        @invoice.tol_fee = tol_fee

        total = gas_allowance + driver_allowance + misc_allowance + helper_allowance + ferry_fee + tol_fee
        @invoice.total = total
      end

      # customer = Customer.find(inputs[:customer_id]) rescue nil
      route = Route.find(@invoice.route_id) rescue nil
      @invoice.customer_id = route.customer_id
      @invoice.price_per = @invoice.route.price_per || 0
      @invoice.insurance = inputs[:insurance].to_i || 0
      rate = Setting.find_by_name("Rate Asuransi").value.to_f rescue nil || 0
      @invoice.insurance_rate = rate
      @invoice.user_id = current_user.id
      
      if @invoice.save
        redirect_to(step2_invoice_url(@invoice))
      else
        to_flash(@invoice)
        render :action => "new"
      end
    else
      redirect_to(invoices_path, :notice => 'BKK dengan Jurusan dan Nopol yang sama telah diinput dengan id #' + zeropad(@invoice_exist.id))
    end
  end

  def update
   #  inputs = params[:invoice]
   #  slug_currency(inputs)

   #  @invoice = Invoice.find(params[:id])
   #  @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
   #  @allowances = Allowance.where(:route_id => @invoice.route_id, :vehiclegroup_id => @invoice.vehiclegroup_id, :deleted => false).first

   #  #different treatment between step 1 and step 2
   
   #  if params["process"].nil?
   #      if inputs[:quantity].to_i != @invoice.quantity   

   #      #reset gas if updated
   #      vehicle = @invoice.vehicle
        
   #      vehicle.gas_leftover = (vehicle.gas_leftover || 0) - (@invoice.gas_voucher - @invoice.gas_start)  if @invoice.gas_start > 0 and @invoice.gas_start < @invoice.gas_voucher
   #      vehicle.gas_leftover = (vehicle.gas_leftover || 0) + @invoice.gas_leftover.to_i
   #      vehicle.save

   #      route = Route.find(@invoice.route_id) rescue nil
   #      @invoice.customer_id = route.customer_id
        
   #      quantity = inputs[:quantity].to_i || 0

   #      @invoice.quantity = quantity
   #      if !@allowances.nil?
   #        @route = Route.find(@invoice.route_id)

   #        driver_allowance = quantity * @allowances.driver_trip
   #        @invoice.driver_allowance = driver_allowance

   #        if @invoice.need_helper
   #          helper_allowance = quantity * @allowances.helper_trip
   #        else
   #          helper_allowance = 0
   #        end

   #        @invoice.helper_allowance = helper_allowance

   #        misc_allowance = quantity * @allowances.misc_allowance
   #        @invoice.misc_allowance = misc_allowance
          
   #        gas_litre = quantity * @allowances.gas_trip
   #        @invoice.gas_litre = gas_litre
   #        @invoice.gas_start = gas_litre
          
   #        gas_allowance = gas_litre * @gascost
   #        @invoice.gas_allowance = gas_allowance

   #        ferry_fee = @route.ferry_fee
   #        @invoice.ferry_fee = ferry_fee

   #        tol_fee = quantity * @route.tol_fee
   #        @invoice.tol_fee = tol_fee

   #        total = gas_allowance + driver_allowance + helper_allowance + misc_allowance + ferry_fee + tol_fee
   #        @invoice.total = total

   #        @invoice.gas_leftover = 0
   #        @invoice.gas_voucher = 0
   #      end
   #    end

   #     @invoice.insurance = inputs[:insurance].to_i || 0
   #     @invoice.description = inputs[:description]
   #  end

   # if params["process"] == 'step2'
      
   #    @invoice.total =  @invoice.total - @invoice.gas_allowance
   #    @invoice.gas_voucher = inputs[:gas_voucher].nil? ? 0 : inputs[:gas_voucher].to_i
   #    @invoice.gas_leftover = inputs[:gas_leftover].nil? ? 0 : inputs[:gas_leftover].to_i
      
   #    gas_litre = @invoice.quantity * @allowances.gas_trip
   #    @invoice.gas_litre = gas_litre -  @invoice.gas_voucher - @invoice.gas_leftover
   #    @invoice.gas_allowance = @invoice.gas_litre < 0 ? 0 : @invoice.gas_litre * @gascost
   #    @invoice.total += @invoice.gas_allowance 
   #  end 
      
   #  @invoice.user_id = current_user.id

   #  if @invoice.save
   #    if params["process"] == 'step2'
   #      vehicle = @invoice.vehicle
   #      vehicle.gas_leftover = (vehicle.gas_leftover || 0) + (@invoice.gas_voucher - @invoice.gas_start)  if @invoice.gas_start > 0 and @invoice.gas_start < @invoice.gas_voucher
   #      vehicle.gas_leftover = (vehicle.gas_leftover || 0) - @invoice.gas_leftover.to_i
   #      vehicle.save

   #      redirect_to(confirmation_invoice_url(@invoice), :notice => 'Data BKK sukses disimpan.')
   #    else
   #      redirect_to(step2_invoice_url(@invoice))
   #    end
   #  else
   #    to_flash(@invoice)
   #    render :action => "edit"
   #  end
   

    inputs = params[:invoice]
    slug_currency(inputs)

    @invoice = Invoice.find(params[:id])

    @invoice_exist = Invoice.where(:route_id => inputs[:route_id], :vehicle_id => inputs[:vehicle_id], :date => inputs[:date].to_date, :deleted => false, :invoice_id => nil).first()

    if params["process"].nil?

      if @invoice_exist.nil?
          @invoice.update_attributes(inputs)
        
          gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance = quantity = total = 0

          @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
          @invoice.gas_cost = @gascost

          quantity = inputs[:quantity].to_i if inputs[:quantity]
          @invoice.quantity = quantity

          @vehicle = Vehicle.find(inputs[:vehicle_id]) rescue nil
          @invoice.vehicle_id = @vehicle.id

          vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
          @invoice.vehiclegroup_id = vehiclegroup_id

          @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false

          @allowances = Allowance.where(:route_id => inputs[:route_id], :vehiclegroup_id => vehiclegroup_id, :deleted => false).first

          if !@allowances.nil?
            @route = Route.find(inputs[:route_id])

            driver_allowance = quantity * @allowances.driver_trip
            @invoice.driver_allowance = driver_allowance

            if @invoice.need_helper
              helper_allowance = quantity * @allowances.helper_trip
            else
              helper_allowance = 0
            end
            @invoice.helper_allowance = helper_allowance

            misc_allowance = quantity * @allowances.misc_allowance
            @invoice.misc_allowance = misc_allowance
            
            gas_litre = quantity * (@allowances.gas_trip || 0)
            @invoice.gas_litre = gas_litre
            @invoice.gas_start = gas_litre
            
            gas_allowance = gas_litre * @gascost
            @invoice.gas_allowance = gas_allowance

            ferry_fee = @route.ferry_fee || 0
            @invoice.ferry_fee = ferry_fee

            tol_fee = quantity * (@route.tol_fee || 0)
            @invoice.tol_fee = tol_fee

            total = gas_allowance + driver_allowance + misc_allowance + helper_allowance + ferry_fee + tol_fee
            @invoice.total = total

            # customer = Customer.find(inputs[:customer_id]) rescue nil
            route = Route.find(@invoice.route_id) rescue nil
            @invoice.customer_id = route.customer_id
            @invoice.price_per = @invoice.route.price_per || 0
            @invoice.insurance = inputs[:insurance].to_i || 0
            rate = Setting.find_by_name("Rate Asuransi").value.to_f rescue nil || 0
            @invoice.insurance_rate = rate
            @invoice.user_id = current_user.id

            if @invoice.save
              redirect_to(step2_invoice_url(@invoice))
            else
              to_flash(@invoice)
              render :action => "edit"
            end
          end
      elsif @invoice_exist.id == @invoice.id
        # customer = Customer.find(inputs[:customer_id]) rescue nil
        @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
        @allowances = Allowance.where(:route_id => @invoice.route_id, :vehiclegroup_id => @invoice.vehiclegroup_id, :deleted => false).first
        route = Route.find(@invoice.route_id) rescue nil
        @invoice.customer_id = route.customer_id
        @invoice.insurance = inputs[:insurance].to_i || 0
        @invoice.description = inputs[:description]
        @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false

        # if inputs[:quantity].to_i != @invoice.quantity
          vehicle = @invoice.vehicle
          
          vehicle.gas_leftover = (vehicle.gas_leftover || 0) - (@invoice.gas_voucher - @invoice.gas_start)  if @invoice.gas_start > 0 and @invoice.gas_start < @invoice.gas_voucher
          vehicle.gas_leftover = (vehicle.gas_leftover || 0) + @invoice.gas_leftover.to_i
          vehicle.save
          
          quantity = inputs[:quantity].to_i || 0

          @invoice.quantity = quantity
          if !@allowances.nil?
            @route = Route.find(@invoice.route_id)

            driver_allowance = quantity * @allowances.driver_trip
            @invoice.driver_allowance = driver_allowance

            if @invoice.need_helper
              helper_allowance = quantity * @allowances.helper_trip
            else
              helper_allowance = 0
            end

            @invoice.helper_allowance = helper_allowance

            misc_allowance = quantity * @allowances.misc_allowance
            @invoice.misc_allowance = misc_allowance
            
            gas_litre = quantity * @allowances.gas_trip
            @invoice.gas_litre = gas_litre
            @invoice.gas_start = gas_litre
            
            gas_allowance = gas_litre * @gascost
            @invoice.gas_allowance = gas_allowance

            ferry_fee = @route.ferry_fee
            @invoice.ferry_fee = ferry_fee

            tol_fee = quantity * @route.tol_fee
            @invoice.tol_fee = tol_fee

            total = gas_allowance + driver_allowance + helper_allowance + misc_allowance + ferry_fee + tol_fee
            @invoice.total = total

            @invoice.gas_leftover = 0
            @invoice.gas_voucher = 0
          end
        # end

        if @invoice.save
          redirect_to(step2_invoice_url(@invoice))
        else
          to_flash(@invoice)
          render :action => "edit"
        end
      else
        redirect_to(invoices_path, :notice => 'BKK dengan Jurusan dan Nopol yang sama telah diinput dengan id #' + zeropad(@invoice_exist.id))  
      end

    end

    if params["process"] == 'step2'
      @allowances = Allowance.where(:route_id => @invoice.route_id, :vehiclegroup_id => @invoice.vehiclegroup_id, :deleted => false).first
      @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    
      @invoice.total =  @invoice.total - @invoice.gas_allowance
      @invoice.gas_voucher = inputs[:gas_voucher].nil? ? 0 : inputs[:gas_voucher].to_i
      @invoice.gas_leftover = inputs[:gas_leftover].nil? ? 0 : inputs[:gas_leftover].to_i
      
      gas_litre = @invoice.quantity * @allowances.gas_trip
      @invoice.gas_litre = gas_litre -  @invoice.gas_voucher - @invoice.gas_leftover
      @invoice.gas_allowance = (@invoice.gas_litre || 0) < 0 ? 0 : (@invoice.gas_litre * @gascost rescue 0)
      @invoice.total += @invoice.gas_allowance

      if @invoice.save
        vehicle = @invoice.vehicle
        vehicle.gas_leftover = (vehicle.gas_leftover || 0) + (@invoice.gas_voucher - @invoice.gas_start)  if @invoice.gas_start > 0 and @invoice.gas_start < @invoice.gas_voucher
        vehicle.gas_leftover = (vehicle.gas_leftover || 0) - @invoice.gas_leftover.to_i
        vehicle.save

        redirect_to(confirmation_invoice_url(@invoice), :notice => 'Data BKK sukses disimpan.')
      else
        to_flash(@invoice)
        render :action => "edit"
      end        
    end
  end

  def get_customer
    @route = Route.find(params[:route_id]) rescue nil
    @customer = Customer.find(@route.customer_id) rescue nil if @route
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/customer"), :layout => false }.to_json; 
  end

  def get_vehiclegroup
    @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
    @vehiclegroup = Vehiclegroup.find(@vehicle.vehiclegroup_id) rescue nil if @vehicle
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/vehiclegroup"), :layout => false }.to_json; 
  end

  def get_vehicles
    @vehicles = Vehicle.where(:vehiclegroup_id => params[:vehiclegroup_id], :enabled => true, :deleted => false) rescue nil
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/vehicles"), :layout => false }.to_json; 
  end

  def get_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id], :deleted => false) rescue nil
    gas_leftover = @vehicle.gas_leftover if @vehicle
    render :json => { :success => true, :gas_leftover => gas_leftover, :layout => false }.to_json; 
  end

  def get_routes
    @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routes", :layout => false) }.to_json; 
  end

  def get_allowances
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance = quantity = total = 0
    quantity = params[:quantity].to_i if params[:quantity]
    @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
    vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
    @allowances = Allowance.where(:route_id => params[:route_id], :vehiclegroup_id => vehiclegroup_id, :deleted => false).first
    if !@allowances.nil?
      @route = Route.find(params[:route_id])

      helper_allowance = params[:ishelper] == 'true' ? quantity * @allowances.helper_trip : 0
      
      driver_allowance = quantity * (@allowances.driver_trip || 0)
      misc_allowance = quantity * (@allowances.misc_allowance || 0)
      gas_litre = quantity * (@allowances.gas_trip || 0)
      gas_allowance = gas_litre * @gascost
      ferry_fee = @route.ferry_fee || 0
      tol_fee = quantity * (@route.tol_fee || 0)

      total = gas_allowance + driver_allowance + misc_allowance + helper_allowance
      total += ferry_fee + tol_fee
      price_per = @route.price_per
    end

    render :json => { :success => true, :layout => false, 
        :price_per => to_currency(price_per) || 0, 
        :gas_allowance => to_currency(gas_allowance), 
        :gas_litre => gas_litre, 
        :driver_allowance => to_currency(driver_allowance), 
        :helper_allowance => to_currency(helper_allowance),
        :misc_allowance => to_currency(misc_allowance) || 0, 
        :ferry_fee => to_currency(ferry_fee), 
        :tol_fee => to_currency(tol_fee), 
        :gas_detail => '(' + gas_litre.to_s + ' liter @ ' + @gascost.to_s + ')', 
        :total => to_currency(total) 
      }.to_json; 
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    
    if @invoice.receipts.where(:deleted => false).any? or @invoice.receiptreturns.where(:deleted => false).any? or @invoice.receiptpremis.where(:deleted => false).any?
      redirect_to(invoices_path, :notice => 'BKK No. #' + zeropad(@invoice.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
      if @invoice.invoicereturns.any?
        @invoice.invoicereturns.each do |invoicereturn|  
          invoicereturn.deleted = true
          invoicereturn.deleteuser_id = current_user.id
          invoicereturn.save
        end
      end
      if @invoice.taxinvoiceitems.any?
        @invoice.taxinvoiceitems.each do |taxinvoiceitem|
          taxinvoiceitem.deleted = true
          taxinvoiceitem.save 
        end
      end

      if @invoice.bonusreceipts.any?
        @invoice.bonusreceipts.each do |bonusreceipt|
          bonusreceipt.deleted = true
          bonusreceipt.deleteuser_id = current_user.id
          bonusreceipt.save
        end
      end

      @invoice.deleteuser_id = current_user.id
      @invoice.deleted = true
      @invoice.save
      redirect_to(invoices_url)
    end
  end  
  
  def enable
    @invoice = Invoice.find(params[:id])
    @invoice.update_attributes(:enabled => true)
    redirect_to(invoices_url)
  end
  
  def disable
    @invoice = Invoice.find(params[:id])
    @invoice.update_attributes(:enabled => false)
    redirect_to(invoices_url)
  end

  def slug_currency inputs
    inputs[:driver_allowance] = inputs[:driver_allowance].gsub('.','').to_i
    inputs[:gas_allowance] = inputs[:gas_allowance].gsub('.','').to_i
    inputs[:ferry_fee] = inputs[:ferry_fee].gsub('.','').to_i
    inputs[:tol_fee] = inputs[:tol_fee].gsub('.','').to_i
    inputs[:total] = inputs[:total].gsub('.','').to_i
  end

  def indexadd
    @where = "invoiceadd"
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
  
    @invoices = Invoice.where("deleted = false and date = ? and invoice_id IS NULL", @date.to_date).order(:id)
    respond_to :html

  end

  def add
    @where = "invoiceadd"
    @errors = Hash.new

    @invoice_id = params[:invoice_id]
    @invoice_ori = Invoice.where(:id =>params[:invoice_id]).first rescue nil

    respond_to :html
  end

  def updateinvoice
    inputs = params[:invoice]
    @invoice = Invoice.new
    @invoice_ori = Invoice.find(inputs[:invoice_id])

    if inputs[:process] == 'create'
      @invoice = @invoice_ori.dup
  
      quantity = inputs[:quantity].to_i
      @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0

      @allowances = Allowance.where(:route_id => @invoice.route_id, :vehiclegroup_id => @invoice.vehiclegroup_id, :deleted => false).first
      if !@allowances.nil?
        @route = Route.find(@invoice.route_id)

        driver_allowance = quantity * @allowances.driver_trip

        if @invoice.need_helper == true
          helper_allowance = quantity * @allowances.helper_trip
        else
          helper_allowance = 0
        end

        misc_allowance = quantity * @allowances.misc_allowance
        gas_litre = quantity * @allowances.gas_trip
        gas_allowance = gas_litre * @gascost
        ferry_fee = @route.ferry_fee
        tol_fee = quantity * @route.tol_fee
        total = gas_allowance + driver_allowance + misc_allowance + tol_fee + helper_allowance

        @invoice.gas_litre = gas_litre
        @invoice.quantity = quantity
        @invoice.gas_voucher = 0
        @invoice.gas_leftover = 0
        @invoice.helper_allowance = helper_allowance
        @invoice.driver_allowance = driver_allowance
        @invoice.misc_allowance = misc_allowance
        @invoice.tol_fee = tol_fee
        @invoice.gas_allowance = gas_allowance
        @invoice.total = total
      end

      @invoice.invoice_id = @invoice_ori.id
      @invoice.date = inputs[:date]
      @invoice.user_id = current_user.id
      @invoice.save

      redirect_to(invoices_path, :notice => 'Data BKK sukses disimpan')
    else
      @invoice_id = inputs[:invoice_id]
      redirect_to("/invoices/add/invoice_id=" + @invoice_id)
    end
  end

end
