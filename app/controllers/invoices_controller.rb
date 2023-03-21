class InvoicesController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => [:get_routes, :get_allowances, :get_vehicles, :get_vehicle, :get_vehiclegroupid, :get_trainroute, :get_trainroute2, :get_shiproute, :get_shiproute2, :get_routesbyoffice, :get_tanktype]
  protect_from_forgery :except => [:add, :updateinvoice, :updateaddweight, :updateship]
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "invoices"
    @transporttypes = ["STANDART", "KERETA"]
    @tanktypes = ["TANGKI BESI", "TANGKI STAINLESS", "ISOTANK", "KONTAINER", "LOSBAK", "DROPSIDE", "TRUK BOX"]
    @tanktypesPadat = ["LOSBAK", "DROPSIDE", "TRUK BOX", "KONTAINER"]
    @tanktypesCair = ["TANGKI BESI", "TANGKI STAINLESS", "ISOTANK"]
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

    if checkroleonly 'Vendor Supir'
      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?

      @offices = Office.active.order('id asc')

      @vendor = Vendor.where('user_id = ?', current_user.id)

      if @vendor.present? 
      # cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
      @invoices = Invoice.find_by_sql("select routes.name, invoices.route_id, invoices.office_id, invoices.vehicle_id, invoices.driver_id, drivers.name, invoices.id, invoices.deleted, invoices.date, invoices.quantity, invoices.description, offices.abbr, invoices.isotank_id, invoices.container_id, invoices.event_id, invoices.total, invoices.by_vendor
                                      from invoices
                                      join drivers ON invoices.driver_id = drivers.id 
                                      join routes ON invoices.route_id = routes.id
                                      join customers ON invoices.customer_id = customers.id
                                      join vendors ON drivers.vendor_id = vendors.id
                                      join vehicles ON invoices.vehicle_id = vehicles.id
                                      join offices ON invoices.office_id = offices.id
                                      where vendors.id = #{@vendor[0].id} AND date = '#{@date.to_date}'
                                      AND invoices.customer_id NOT IN (SELECT id from customers WHERE name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*') ORDER BY invoices.id")
      
      end

    else

      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      # @invoices = Invoice.where("date = ? and invoicetrain is false", @date.to_date).order(:id)
      @invoices = Invoice.where("date = ? and invoicetrain is false", @date.to_date)
      
      cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
  
      @invoices = @invoices.where("customer_id NOT IN (?)", cust_kosongan).order(:id)
      # fetch_excel()
        
      @office_id = params[:office_id]
        
      if @office_id.present? and @office_id != "all"
          @invoices = @invoices.where("office_id = ?", @office_id)
      end
        
      @offices = Office.active.order('id asc')  
      @office_role = []
        
      if checkrole 'BKK Kantor Sidoarjo'
          @office_role.push(1)
      end
      if checkrole 'BKK Kantor Jakarta'
          @office_role.push(2)
      end
      if checkrole 'BKK Kantor Probolinggo'
          @office_role.push(3)
      end    
      if checkrole 'BKK Kantor Semarang'
          @office_role.push(4)
      end
      if checkrole 'BKK Kantor Surabaya'
        @office_role.push(5)
      end
      if checkrole 'BKK Kantor Sumatera'
        @office_role.push(6)
      end
      # if checkrole 'BKK Cargo Padat'
      #   @office_role.push(7)
      # end
      
      if checkrole 'Operasional BKK'
          @offices = @offices.where('id != 7').order('id asc')
      else
          @offices = @offices.where('id IN (?)', @office_role).order('id asc')
      end


    end
  
    respond_to :html
  end
    
  def kosongan
    @where = "invoices_kosongan"

    if checkroleonly 'Vendor Supir'

      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?

      @offices = Office.active.order('id asc')

      @vendor = Vendor.where('user_id = ?', current_user.id)
        
      if @vendor.present? 

      # cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
      @invoices = Invoice.find_by_sql("select routes.name, invoices.route_id, invoices.office_id, invoices.vehicle_id, invoices.driver_id, drivers.name, invoices.id, invoices.deleted, invoices.date, invoices.quantity, invoices.description, offices.abbr, invoices.isotank_id, invoices.container_id, invoices.event_id, invoices.total, invoices.by_vendor
                                      from invoices
                                      join drivers ON invoices.driver_id = drivers.id 
                                      join routes ON invoices.route_id = routes.id
                                      join customers ON invoices.customer_id = customers.id
                                      join vendors ON drivers.vendor_id = vendors.id
                                      join vehicles ON invoices.vehicle_id = vehicles.id
                                      join offices ON invoices.office_id = offices.id
                                      where vendors.id = #{@vendor[0].id} AND date = '#{@date.to_date}'
                                      AND invoices.customer_id IN (SELECT id from customers WHERE name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*') ORDER BY invoices.id")

      end
      
    else

      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
        
      @invoices = Invoice.where("date = ? and invoicetrain is false", @date.to_date)

      cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)

      @invoices = @invoices.where("customer_id IN (?)", cust_kosongan).order(:id)
        
      @office_id = params[:office_id]
        
      if @office_id.present? and @office_id != "all"
          @invoices = @invoices.where("office_id = ?", @office_id)
      end
        
      @offices = Office.active.order('id asc')  
      @office_role = []
        
      if checkrole 'BKK Kantor Sidoarjo'
          @office_role.push(1)
      end
      if checkrole 'BKK Kantor Jakarta'
          @office_role.push(2)
      end
      if checkrole 'BKK Kantor Probolinggo'
          @office_role.push(3)
      end    
      if checkrole 'BKK Kantor Semarang'
          @office_role.push(4)
      end
      if checkrole 'BKK Kantor Surabaya'
        @office_role.push(5)
      end
      if checkrole 'BKK Kantor Sumatera'
        @office_role.push(6)
      end
      # if checkrole 'BKK Cargo Padat'
      #   @office_role.push(7)
      # end
      
      if checkrole 'Operasional BKK'
          @offices = @offices.where('id != 7').order('id asc')
      else
          @offices = @offices.where('id IN (?)', @office_role).order('id asc')
      end
    
    end
 
  end

  def new
#    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0

    if params[:train] || params[:train] == true 
      @where = "indexinvoicetrain"
      @tanktypes = ["ISOTANK", "KONTAINER"]
    end
		
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.new
    # @invoice.office_id = current_user.office_id rescue nil || 1 
    @iseditable = true
    @invoice.enabled = true
    @invoice.date = Date.today
      
    @isotanks = Isotank.active.order(:isotanknumber)
    @isotanks = @isotanks.where("isotanknumber IN ('NLLU 2902068','NLLU 2902073','NLLU 2902089','NLLU 2902094','NLLU 2902108','NLLU 2902113','NLLU 2902129','NLLU 2902134','NLLU 2902140','NLLU 2902155','NLLU 2902284','NLLU 2902290','NLLU 2902303','NLLU 2902319','NLLU 2902324','NLLU 2902330','NLLU 2902345','NLLU 2902350','NLLU 2902366','NLLU 2902371','NLLU 2900764','NLLU 2900770','NLLU 2900785','NLLU 2900790','NLLU 2900804','NLLU 2900810','NLLU 2900825','NLLU 2900830','NLLU 2900846','NLLU 2900851','NLLU 2901380','NLLU 2901415','NLLU 2901800','NLLU 2901816','NLLU 2901842','NLLU 2901159','NLLU 2901190','NLLU 2901210','NLLU 2901225','NLLU 9700027','NLLU 2800277','NLLU 2800282','NLLU 2800298','SAXU 2705112','SAXU 2705468','NLLU 2900907','NLLU 2900912','NLLU 2900928','NLLU 2900949','NLLU 2901077','NLLU 2901082','NLLU 2901117','NLLU 2901122','NLLU 2901138','NLLU 2901164','NLLU 2902746','NLLU 2902751','NLLU 2902767','NLLU 2902772','NLLU 2902788','NLLU 2902793','NLLU 2902807','NLLU 2902812','NLLU 2902828','NLLU 2902833','NLLU 2902849','NLLU 2902854','NLLU 2902860','NLLU 2902875','NLLU 2900070','NLLU 2900105','NLLU 2900173','NLLU 2900189','NLLU 2900424','NLLU 2900430')")
      
    @offices = Office.active  
    @office_role = []
      
    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end    
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
        @office_role.push(6)
    end
    # if checkrole 'BKK Cargo Padat'
    #     @office_role.push(7)
    # end
    
    if checkrole 'Operasional BKK'
        @offices = @offices.where('id != 7').order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end
 
  end

  def indexaddweight
    @section = "ops"
    @where = "addweight"
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    # @invoices = Invoice.where("date = ? and invoicetrain is false", @date.to_date).order(:id)
    @invoices = Invoice.where("date = ? and deleted = false", @date.to_date)
    
    cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)

    @invoices = @invoices.where("customer_id NOT IN (?)", cust_kosongan).order(:id)
    # fetch_excel()
      
    @office_id = params[:office_id]
      
    if @office_id.present? and @office_id != "all"
        @invoices = @invoices.where("office_id = ?", @office_id)
    end
      
    @offices = Office.active.order('id asc')  
    @office_role = []
      
    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end    
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
      @office_role.push(6)
    end
    # if checkrole 'BKK Cargo Padat'
    #   @office_role.push(7)
    # end
    
    if checkrole 'Operasional BKK'
        @offices = @offices.where('id != 7').order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end
        
  
    respond_to :html
  end

  def add_weight
    @section = "ops"
    @where = "addweight"
    @invoice = Invoice.find(params[:invoice_id])

    if @invoice.load_date.nil?
      @invoice.load_date = Date.today
    end

  end

  def updateship

    inputs = params[:invoice]

    @invoice = Invoice.find(inputs[:invoice_id])
    
    @invoice.shipoperator_id = inputs[:shipoperator_id]
    @invoice.routeship_id = inputs[:routeship_id] 

    if @invoice.save
      redirect_to("/invoices/add_ship/"+@invoice.id.to_s)
    end

  end

  def indexaddship
    @section = "ops"
    @where = "addship"
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    
    @invoices = Invoice.where("date = ? and deleted = false", @date.to_date)

    @invoices = @invoices.where("invoices.id not in (select invoice_id from shipexpenses where deleted = false)")
    
    cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)

    @invoices = @invoices.where("customer_id NOT IN (?)", cust_kosongan).order(:id)
    # fetch_excel()
      
    @invoice_id = params[:invoice_id]

    if @invoice_id.present?
      @invoices = Invoice.where("id = ? and deleted = false", @invoice_id)
    end

    @office_id = params[:office_id]
      
    if @office_id.present? and @office_id != "all"
        @invoices = @invoices.where("office_id = ?", @office_id)
    end
      
    @offices = Office.active.order('id asc')  
    @office_role = []
      
    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end    
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
      @office_role.push(6)
    end
    # if checkrole 'BKK Cargo Padat'
    #   @office_role.push(7)
    # end
    
    if checkrole 'Operasional BKK'
        @offices = @offices.where('id != 7').order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end
        
  
    respond_to :html
  end

  def add_ship
    @section = "ops"
    @where = "addship"
    @invoice = Invoice.find(params[:invoice_id])

    if @invoice.load_date.nil?
      @invoice.load_date = Date.today
    end

  end

  def edit
    @invoice = Invoice.find(params[:id])
    @invoice_ori = Invoice.where(:id =>params[:invoice_id]).first rescue nil
    @gascost = @invoice.gas_cost.to_i 
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0 if @invoice.gas_cost.nil?
    @iseditable = false
      
    if params[:train] || params[:train] == true 
      @where = "indexinvoicetrain"
      @tanktypes = ["ISOTANK", "KONTAINER"]
    end

    # if @invoice.tanktype == 'STANDART'
    #     @invoice.tanktype = 'TANGKI BESI'
    # end

    @isotanks = Isotank.active.order(:isotanknumber)
    @isotanks = @isotanks.where("isotanknumber IN ('NLLU 2902068','NLLU 2902073','NLLU 2902089','NLLU 2902094','NLLU 2902108','NLLU 2902113','NLLU 2902129','NLLU 2902134','NLLU 2902140','NLLU 2902155','NLLU 2902284','NLLU 2902290','NLLU 2902303','NLLU 2902319','NLLU 2902324','NLLU 2902330','NLLU 2902345','NLLU 2902350','NLLU 2902366','NLLU 2902371','NLLU 2900764','NLLU 2900770','NLLU 2900785','NLLU 2900790','NLLU 2900804','NLLU 2900810','NLLU 2900825','NLLU 2900830','NLLU 2900846','NLLU 2900851','NLLU 2901380','NLLU 2901415','NLLU 2901800','NLLU 2901816','NLLU 2901842','NLLU 2901159','NLLU 2901190','NLLU 2901210','NLLU 2901225','NLLU 9700027','NLLU 2800277','NLLU 2800282','NLLU 2800298','SAXU 2705112','SAXU 2705468','NLLU 2900907','NLLU 2900912','NLLU 2900928','NLLU 2900949','NLLU 2901077','NLLU 2901082','NLLU 2901117','NLLU 2901122','NLLU 2901138','NLLU 2901164','NLLU 2902746','NLLU 2902751','NLLU 2902767','NLLU 2902772','NLLU 2902788','NLLU 2902793','NLLU 2902807','NLLU 2902812','NLLU 2902828','NLLU 2902833','NLLU 2902849','NLLU 2902854','NLLU 2902860','NLLU 2902875','NLLU 2900070','NLLU 2900105','NLLU 2900173','NLLU 2900189','NLLU 2900424','NLLU 2900430')")
      

    @offices = Office.active  
    @office_role = []
      
    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end    
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
        @office_role.push(6)
    end
    # if checkrole 'BKK Cargo Padat'
    #   @office_role.push(7)
    # end
    
    if checkrole 'Operasional BKK'
        @offices = @offices.where('id != 7').order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end

  end

  def edit_updated
  end

  def step2
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.find(params[:id])
    respond_to :html
  end

  def confirmation
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.find(params[:id])

    @routelocation = Routelocation.where('route_id = ?', @invoice.route_id).first rescue nil

    # ssl = request.ssl?
    # if ssl
    #   # respond_to :html
    # redirect_to :protocol => 'http://', 
    #         :controller => 'invoices', 
    #         :action => 'confirmation'
    # end
    respond_to :html
    
  end

  def create

      inputs = params[:invoice]
      slug_currency(inputs)

      if inputs[:invoicetrain] == true
          inputs[:transporttype] ="KERETA"
      end

      @invoice = Invoice.new

      @invoice.update_attributes(inputs)

      gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance = quantity = total = 0

      @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
      @invoice.gas_cost = @gascost

      quantity = inputs[:quantity].to_i if inputs[:quantity]
      @invoice.quantity = quantity

      @vehicle = Vehicle.find(inputs[:vehicle_id]) rescue nil
      @invoice.vehicle_id = @vehicle.id
      @vehicle_year = @vehicle.year_made

      vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
      @invoice.vehiclegroup_id = vehiclegroup_id

      year_made = @vehicle.year_made.to_i if @vehicle
      year_diff = 0

      if !year_made.blank? && year_made.to_i > 1000
          year_diff = Date.current.year - year_made
      end

      @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false
      @invoice.premi = inputs[:premi] == "Yes" ? true : false
      @invoice.is_insurance = inputs[:is_insurance] == "Yes" ? true : false
      @invoice.by_vendor = inputs[:by_vendor] == "Yes" ? true : false

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

          if @invoice.premi
              premi_allowance = quantity * @route.bonus
          else
              premi_allowance = 0
          end 
          @invoice.premi_allowance = premi_allowance

          misc_allowance = quantity * @allowances.misc_allowance
          @invoice.misc_allowance = misc_allowance

          if @invoice.misc_allowance < 200
              @invoice.misc_allowance = misc_allowance * 10000
          end

          gas_litre = quantity * @allowances.gas_trip
          @additional_gas_allowance = 0

          # if year_diff >= 15
          #     gas_litre += gas_litre.to_i * year_diff.to_i / 100
          #     puts "===> gas litre >= 15y"
          #     puts gas_litre
          #     @additional_gas_allowance = (gas_litre.to_i * year_diff.to_i / 100) * @gascost
          #     puts "===> additional allowances"
          #     puts @additional_gas_allowance
          # end

          #SOLAR TAMBAHAN utk SIL 8 & build up
          if vehiclegroup_id == 4 || vehiclegroup_id == 5
            gas_litre = gas_litre + (gas_litre.to_i*10/100)
          end

          @invoice.gas_litre = gas_litre
          @invoice.gas_start = gas_litre
          gas_allowance = gas_litre * @gascost
          @invoice.gas_allowance = gas_allowance

          ferry_fee = @route.ferry_fee || 0
          @invoice.ferry_fee = ferry_fee

          tol_fee = quantity * (@route.tol_fee || 0)
          @invoice.tol_fee = tol_fee

          total = gas_allowance + driver_allowance + misc_allowance + helper_allowance + ferry_fee + tol_fee + premi_allowance
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
      @invoice.incentive = @invoice.vehicle.vehicleincentivegroup.incentive.to_f rescue 0

      if inputs[:invoicetrain] == true
          @invoice.transporttype = "KERETA"
      end

      if @invoice.save
          redirect_to(step2_invoice_url(@invoice))
      else
          to_flash(@invoice)
          render :action => "new"
      end
  end

  def update

  puts '===========> update'

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
          @vehicle_year = @vehicle.year_made
          year_made = @vehicle.year_made.to_i if @vehicle

          vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
          @invoice.vehiclegroup_id = vehiclegroup_id

          year_diff = 0

          if !year_made.blank? && year_made.to_i > 1000
              year_diff = Date.current.year.to_i-year_made
          else
              puts "tahun tak ada"
          end

        @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false

        @invoice.premi = inputs[:premi] == "Yes" ? true : false

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

          if @invoice.premi
            premi_allowance = quantity * @invoice.premi_allowance
          else
            premi_allowance = 0
          end 
          @invoice.premi_allowance = premi_allowance

          misc_allowance = quantity * @allowances.misc_allowance
          @invoice.misc_allowance = misc_allowance

          puts '===> misc allowance'
          puts @allowances.misc_allowance
          puts misc_allowance
          puts @invoice.misc_allowance

          if @invoice.misc_allowance < 200
            @invoice.misc_allowance = misc_allowance * 10000
          end

          gas_litre = quantity * (@allowances.gas_trip || 0)
          @additional_gas_allowance = 0

          if year_diff >= 15
              gas_litre += gas_litre.to_i * year_diff.to_i / 100
              puts "===> gas litre >= 15y"
              puts gas_litre
              @additional_gas_allowance = (gas_litre.to_i * year_diff.to_i / 100) * @gascost
          end

          @invoice.gas_litre = gas_litre
          @invoice.gas_start = gas_litre

          gas_allowance = gas_litre * @gascost
          @invoice.gas_allowance = gas_allowance

          ferry_fee = @route.ferry_fee || 0
          @invoice.ferry_fee = ferry_fee

          tol_fee = quantity * (@route.tol_fee || 0)
          @invoice.tol_fee = tol_fee

          total = gas_allowance + driver_allowance + misc_allowance + helper_allowance + ferry_fee + tol_fee + premi_allowance
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

      @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
      @allowances = Allowance.where(:route_id => @invoice.route_id, :vehiclegroup_id => @invoice.vehiclegroup_id, :deleted => false).first
      route = Route.find(@invoice.route_id) rescue nil
      @invoice.customer_id = route.customer_id
      @invoice.insurance = inputs[:insurance].to_i || 0
      @invoice.description = inputs[:description]
      @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false

      @invoice.premi = inputs[:premi] == "Yes" ? true : false

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

          if @invoice.premi
            premi_allowance = quantity * @route.bonus
          else
            premi_allowance = 0
          end 

          @invoice.premi_allowance = premi_allowance

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

          total = gas_allowance + driver_allowance + helper_allowance + misc_allowance + ferry_fee + tol_fee + premi_allowance
          @invoice.total = total

          @invoice.gas_leftover = 0
          @invoice.gas_voucher = 0 
        end

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

    gas_litre = @invoice.quantity * (@allowances.gas_trip || 0)
    @invoice.gas_litre = @invoice.gas_litre -  @invoice.gas_voucher - @invoice.gas_leftover
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

  def get_vehicles_by_office_id
    # Sby, Prb, Smt, CP
    if params[:office_id] == '3' || params[:office_id] == '5' || params[:office_id] == '6' || params[:office_id] == '7'
        @vehicles = Vehicle.where(:office_id => params[:office_id], :enabled => true, :deleted => false).order('current_id ASC') rescue nil
        render :json => { :success => true, :html => render_to_string(:partial => "invoices/vehicles_new"), :layout => false }.to_json;
    else  
        @vehicles = Vehicle.where('enabled = true AND deleted = false AND office_id NOT IN (3,5,6,7)').order('current_id ASC') rescue nil
        render :json => { :success => true, :html => render_to_string(:partial => "invoices/vehicles_new"), :layout => false }.to_json;
    end
  end

  def get_vehicle
    @vehicle = Vehicle.find(params[:vehicle_id], :deleted => false) rescue nil
    gas_leftover = @vehicle.gas_leftover if @vehicle
		year_made = @vehicle.year_made if @vehicle
    render :json => { :success => true, :gas_leftover => gas_leftover, :year_made => year_made, :layout => false }.to_json;
		@vehicle_year = @vehicle.year_made
		puts "Test ya"+@vehicle_year
		
  end

  def get_routes
      
    is_train = params[:train]
    customer_id = params[:customer_id]  
      
    if is_train == "0"
        
        #customer kosongan pura / rdpi
        cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)

        if cust_kosongan.include? params[:customer_id].to_i
            
            @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).order(:name)
        
        else
            
            @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).where("name !~* '.*depo.*'").order(:name)
            
        end
        
    else
        
        @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).where("name ~* '.*depo.*'").order(:name)
        
    end
        
    render :json => { :success => true, :train => is_train, :html => render_to_string(:partial => "invoices/routes", :layout => false) }.to_json; 
  end

  def get_routesbyoffice
    
    is_train = params[:train]
    office_id = params[:office_id]  
      
    if is_train == "0"

        @routes = Route.where(:office_id => params[:office_id], :enabled => true, :deleted => false).order(:name)
        # @routes = Route.where(:office_id => params[:office_id], :enabled => true, :deleted => false).where("name !~* '.*depo.*'").order(:name)
        
    else
        
        @routes = Route.where(:office_id => params[:office_id], :enabled => true, :deleted => false).where("name ~* '.*depo.*'").order(:name)
        
    end
        
    render :json => { :success => true, :train => is_train, :html => render_to_string(:partial => "invoices/routes", :layout => false) }.to_json; 
  end

  def get_routeswithtype
    # render json: params
    # return false
    # @routes = Route.where(:customer_id => params[:customer_id], :transporttype => params[:transporttype], :enabled => true, :deleted => false).order(:name)
    @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routes", :layout => false) }.to_json; 
  end

  def get_routesonly
    # render json: params
    # return false
    # @routes = Route.where(:customer_id => params[:customer_id], :transporttype => params[:transporttype], :enabled => true, :deleted => false).order(:name)
    @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routes_for_events", :layout => false) }.to_json; 
  end

  def get_trainroute
    @routes = Routetrain.where(:operator_id => params[:operator_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routetrains", :layout => false) }.to_json; 
  end

  def get_trainroute2
    @routes = Routetrain.where(:operator_id => params[:operator_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routetrains_for_events", :layout => false) }.to_json; 
  end

  def get_shiproute
    @routes = Routeship.where(:operator_id => params[:operator_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routeships", :layout => false) }.to_json; 
  end

  def get_shiproute2
    @routes = Routeship.where(:operator_id => params[:operator_id], :enabled => true, :deleted => false).order(:name)
    render :json => { :success => true, :html => render_to_string(:partial => "invoices/routeships_for_events", :layout => false) }.to_json; 
  end

  def get_routes2
    @routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).order(:name)
    if params[:type] == "0"
      render :json => { :success => true, :html => render_to_string(:partial => "invoices/routes2", :layout => false) }.to_json; 
    else
      render :json => { :success => true, :html => render_to_string(:partial => "invoices/routes3", :layout => false) }.to_json; 
    end
  end

  def get_driverphone
    @driver = Driver.find(params[:driver_id]) rescue nil
    render :json => { :success => true, :driver_phone => @driver.mobile, :layout => false }.to_json; 
  end


  def get_tanktype
    if params[:cargotype] == 'padat'
      @tanktypesPadat = ["LOSBAK", "DROPSIDE", "TRUK BOX", "KONTAINER"]
      @tanktypes = @tanktypesPadat
      render :json => { :success => true, :html => render_to_string(:partial => "invoices/tanktypes", :layout => false) }.to_json; 
    else
      @tanktypesCair = ["TANGKI BESI", "TANGKI STAINLESS", "ISOTANK"]
      @tanktypes = @tanktypesCair
      render :json => { :success => true, :html => render_to_string(:partial => "invoices/tanktypes", :layout => false) }.to_json; 
    end
    
    
  end

  def get_allowances
    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance = quantity = total = 0
    quantity = params[:quantity].to_i if params[:quantity]
    @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
    vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
		year_made = @vehicle.year_made.to_i if @vehicle
		year_diff = 0

		if !year_made.blank? && year_made.to_i > 1000
			current_year = 2019
			year_diff = current_year.to_i-year_made.to_i
		else
			puts "tahun tak ada"
		end
		
    @allowances = Allowance.where(:route_id => params[:route_id], :vehiclegroup_id => vehiclegroup_id, :deleted => false).first
    if !@allowances.nil?
      @route = Route.find(params[:route_id])

      premi_allowance = params[:ispremi] == 'true' ? quantity * @route.bonus : 0
      helper_allowance = params[:ishelper] == 'true' ? quantity * @allowances.helper_trip : 0
      
      driver_allowance = quantity * (@allowances.driver_trip || 0)
      misc_allowance = quantity * (@allowances.misc_allowance || 0)
			gas_litre_ori = quantity * (@allowances.gas_trip || 0)
      gas_litre = quantity * (@allowances.gas_trip || 0)
			additional_gas_detail = 0
			additional_gas_allowance = 0

      #SOLAR TAMBAHAN utk SIL 8 & build up
      if vehiclegroup_id == 4 || vehiclegroup_id == 5
        gas_litre = gas_litre + (gas_litre.to_i*10/100)
        additional_gas_detail = gas_litre - gas_litre_ori
        additional_gas_allowance = (gas_litre.to_i*10/100) * @gascost
      end
			
			# if year_diff >= 15
			# 	gas_litre = gas_litre + (gas_litre.to_i*year_diff.to_i/100)
			# 	additional_gas_detail = gas_litre - gas_litre_ori
			# 	additional_gas_allowance = (gas_litre.to_i*year_diff.to_i/100) * @gascost
			# end
			
      gas_allowance = gas_litre * @gascost
      ferry_fee = @route.ferry_fee || 0
      tol_fee = quantity * (@route.tol_fee || 0)

      train_trip = @allowances.train_trip || 0

      total = gas_allowance + driver_allowance + misc_allowance + helper_allowance + train_trip + premi_allowance
      total += ferry_fee + tol_fee
      price_per = @route.price_per
    end

    incentive = @vehicle.vehicleincentivegroup.incentive rescue 0

    render :json => { :success => true, :layout => false, 
        :incentive => to_currency(incentive), 
        :price_per => to_currency(price_per) || 0, 
        :gas_allowance => to_currency(gas_allowance), 
        :gas_litre => gas_litre, 
        :driver_allowance => to_currency(driver_allowance), 
        :helper_allowance => to_currency(helper_allowance),
        :misc_allowance => to_currency(misc_allowance) || 0, 
        :ferry_fee => to_currency(ferry_fee), 
        :tol_fee => to_currency(tol_fee), 
        :gas_detail => '(' + gas_litre.to_s + ' liter @ ' + @gascost.to_s + ')', 
        :additional_gas_detail => '(' + additional_gas_detail.to_s + ' liter)', 
        :additional_gas_allowance => to_currency(additional_gas_allowance),
        :train_trip => to_currency(train_trip),
        :premi_allowance => to_currency(premi_allowance),
        :total => to_currency(total) 
      }.to_json; 
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    
    if @invoice.receipts.where(:deleted => false).any? or @invoice.receiptreturns.where(:deleted => false).any? or @invoice.receiptpremis.where(:deleted => false).any?
      redirect_to(invoices_path, :notice => 'BKK No. #' + zeropad(@invoice.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
      if @invoice.invoices.any? && @invoice.invoicetrain
        @child_inv = @invoice.invoices.first

        if @child_inv.invoicereturns.any?
          @child_inv.invoicereturns.each do |invoicereturn|  
            invoicereturn.deleted = true
            invoicereturn.deleteuser_id = current_user.id
            invoicereturn.save
          end
        end
        if @child_inv.taxinvoiceitems.any?
          @child_inv.taxinvoiceitems.each do |taxinvoiceitem|
            taxinvoiceitem.deleted = true
            taxinvoiceitem.save 
          end
        end

        if @child_inv.bonusreceipts.any?
          @child_inv.bonusreceipts.each do |bonusreceipt|
            bonusreceipt.deleted = true
            bonusreceipt.deleteuser_id = current_user.id
            bonusreceipt.save
          end
        end

        if @child_inv.incentives.any?
          @child_inv.incentives.each do |incentive|
            incentive.deleted = true
            incentive.deleteuser_id = current_user.id
            incentive.save
          end
        end

        @child_inv.deleteuser_id = current_user.id
        @child_inv.deleted = true
        @child_inv.save        
      end

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

      if @invoice.incentives.any?
        @invoice.incentives.each do |incentive|
          incentive.deleted = true
          incentive.deleteuser_id = current_user.id
          incentive.save
        end
      end

      @invoice.deleteuser_id = current_user.id
      @invoice.deleted = true
      @invoice.save
      redirect_to request.referrer
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
  
    @invoices = Invoice.where("deleted = false and invoicetrain = false and date = ? and invoice_id IS NULL", @date.to_date).order(:id)
    respond_to :html

  end

  def indexinvoicetrain
    @where = "indexinvoicetrain"

    if checkroleonly 'Vendor Supir'
      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      @enddate =  @enddate.nil? ? Date.today.strftime('%d-%m-%Y') : params[:enddate]

      @offices = Office.active.order('id asc')

      @vendor = Vendor.where('user_id = ?', current_user.id)

      if @vendor.present? 
      # cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
      @invoices = Invoice.find_by_sql("select routes.name, invoices.route_id, invoices.office_id, invoices.vehicle_id, invoices.driver_id, drivers.name, invoices.id, invoices.deleted, invoices.date, invoices.quantity, invoices.description, offices.abbr, invoices.isotank_id, invoices.container_id, invoices.event_id, invoices.total, invoices.by_vendor
                                      from invoices
                                      join drivers ON invoices.driver_id = drivers.id 
                                      join routes ON invoices.route_id = routes.id
                                      join customers ON invoices.customer_id = customers.id
                                      join vendors ON drivers.vendor_id = vendors.id
                                      join vehicles ON invoices.vehicle_id = vehicles.id
                                      join offices ON invoices.office_id = offices.id
                                      where vendors.id = #{@vendor[0].id} AND date between '#{@date.to_date}' and '#{@enddate.to_date}'
                                      AND invoicetrain = true and invoice_id IS NULL ORDER BY invoices.id")
      
      end
    else

      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      @enddate =  @enddate.nil? ? Date.today.strftime('%d-%m-%Y') : params[:enddate]
      @container_id = params[:container_id]
      @isotank_id = params[:isotank_id]
      @event_id = params[:event_id]
  
      @invoices = Invoice.where("invoicetrain = true and invoice_id IS NULL AND date between ? and ?", @date.to_date, @enddate.to_date).order(:id)
          
      @office_id = params[:office_id]
    
      if @office_id.present? and @office_id != ''
          @invoices = @invoices.where("office_id = ?", @office_id)
      end
        
      @offices = Office.active.order('id asc')  
      @office_role = []
        
      if checkrole 'BKK Kantor Sidoarjo'
          @office_role.push(1)
      end
      if checkrole 'BKK Kantor Jakarta'
          @office_role.push(2)
      end
      if checkrole 'BKK Kantor Probolinggo'
          @office_role.push(3)
      end    
      if checkrole 'BKK Kantor Semarang'
          @office_role.push(4)
      end
      if checkrole 'BKK Kantor Surabaya'
        @office_role.push(5)
      end
      if checkrole 'BKK Kantor Sumatera'
        @office_role.push(6)
      end
      # if checkrole 'BKK Cargo Padat'
      #   @office_role.push(7)
      # end
      
      if checkrole 'Operasional BKK'
          @offices = @offices.where('id != 7').order('id asc')
      else
          @offices = @offices.where('id IN (?)', @office_role).order('id asc')
      end
  
      if @isotank_id.present?
        @invoices = @invoices.where('isotank_id = ?', @isotank_id)
      end
  
      if @container_id.present?
        @invoices = @invoices.where('container_id = ?', @container_id)
      end
  
      if @event_id.present?
        @invoices = @invoices.where('event_id = ?', @event_id)
      end
      
      office_id = params[:office_id]
  
      if office_id.present?
          @invoices = @invoices.where("office_id = ?", office_id)
      end

    end


    respond_to :html

  end

  def indextrainrequest
    @section = 'ops'
    @where = "indextrainrequest"
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @enddate =  @enddate.nil? ? Date.today.strftime('%d-%m-%Y') : params[:enddate]
    @container_id = params[:container_id]
    @isotank_id = params[:isotank_id]
    @event_id = params[:event_id]

    @invoices = Invoice.where("invoicetrain = true and invoice_id IS NULL AND date between ? and ?", @date.to_date, @enddate.to_date).order(:id)
        
    @office_id = params[:office_id]
  
    if @office_id.present? and @office_id != ''
        @invoices = @invoices.where("office_id = ?", @office_id)
    end
      
    @offices = Office.active.order('id asc')  
    @office_role = []
      
    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end    
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
      @office_role.push(6)
    end
    # if checkrole 'BKK Cargo Padat'
    #   @office_role.push(7)
    # end
    
    if checkrole 'Operasional BKK'
        @offices = @offices.where('id != 7').order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end

    if @isotank_id.present?
      @invoices = @invoices.where('isotank_id = ?', @isotank_id)
    end

    if @container_id.present?
      @invoices = @invoices.where('container_id = ?', @container_id)
    end

    if @event_id.present?
      @invoices = @invoices.where('event_id = ?', @event_id)
    end
    
    office_id = params[:office_id]

    if office_id.present?
        @invoices = @invoices.where("office_id = ?", office_id)
    end

    respond_to :html

  end

  def add
    @where = "invoiceadd"
    @errors = Hash.new

    @invoice_id = params[:invoice_id]
    @invoice_ori = Invoice.where(:id =>params[:invoice_id]).first rescue nil

    respond_to :html
  end

  def adddriver
    @where = "invoiceaddriver"

    @tanktypes = ["ISOTANK", "KONTAINER"]
      
    @isotanks = Isotank.active.order(:isotanknumber)
    @isotanks = @isotanks.where("isotanknumber IN ('NLLU 2902068','NLLU 2902073','NLLU 2902089','NLLU 2902094','NLLU 2902108','NLLU 2902113','NLLU 2902129','NLLU 2902134','NLLU 2902140','NLLU 2902155','NLLU 2902284','NLLU 2902290','NLLU 2902303','NLLU 2902319','NLLU 2902324','NLLU 2902330','NLLU 2902345','NLLU 2902350','NLLU 2902366','NLLU 2902371','NLLU 2900764','NLLU 2900770','NLLU 2900785','NLLU 2900790','NLLU 2900804','NLLU 2900810','NLLU 2900825','NLLU 2900830','NLLU 2900846','NLLU 2900851','NLLU 2901380','NLLU 2901415','NLLU 2901800','NLLU 2901816','NLLU 2901842','NLLU 2901159','NLLU 2901190','NLLU 2901210','NLLU 2901225','NLLU 9700027','NLLU 2800277','NLLU 2800282','NLLU 2800298','SAXU 2705112','SAXU 2705468','NLLU 2900907','NLLU 2900912','NLLU 2900928','NLLU 2900949','NLLU 2901077','NLLU 2901082','NLLU 2901117','NLLU 2901122','NLLU 2901138','NLLU 2901164','NLLU 2902746','NLLU 2902751','NLLU 2902767','NLLU 2902772','NLLU 2902788','NLLU 2902793','NLLU 2902807','NLLU 2902812','NLLU 2902828','NLLU 2902833','NLLU 2902849','NLLU 2902854','NLLU 2902860','NLLU 2902875','NLLU 2900070','NLLU 2900105','NLLU 2900173','NLLU 2900189','NLLU 2900424','NLLU 2900430')")
      
    @offices = Office.active  
    @office_role = []
      
    if checkrole 'BKK Kantor Sidoarjo'
        @office_role.push(1)
    end
    if checkrole 'BKK Kantor Jakarta'
        @office_role.push(2)
    end
    if checkrole 'BKK Kantor Probolinggo'
        @office_role.push(3)
    end    
    if checkrole 'BKK Kantor Semarang'
        @office_role.push(4)
    end
    if checkrole 'BKK Kantor Surabaya'
      @office_role.push(5)
    end
    if checkrole 'BKK Kantor Sumatera'
        @office_role.push(6)
    end
    if checkrole 'BKK Cargo Padat'
        @office_role.push(7)
    end
    
    if checkrole 'Operasional BKK'
        @offices = @offices.order('id asc')
    else
        @offices = @offices.where('id IN (?)', @office_role).order('id asc')
    end

    # @errors = Hash.new

    @invoice_id = params[:invoice_id]
    @invoice_ori = Invoice.where(:id =>params[:invoice_id]).first rescue nil

    @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
    @invoice = Invoice.new
    @invoice.assign_attributes({
      container_id: @invoice_ori.container_id,
      isotank_id: @invoice_ori.isotank_id,
      tanktype: @invoice_ori.tanktype,
      invoicetrain: @invoice_ori.invoicetrain,
      # office_id: @invoice_ori.office_id,
      date: @invoice_ori.date,
    })
    
    # @invoice.office_id = current_user.office_id rescue nil || 0 
    @iseditable = true
    @invoice.enabled = true
    @invoice.date = Date.today
    @invoice.invoice_id = @invoice_id
    @invoice.invoicetrain = true
    @invoice.isotank_id = @invoice_ori.isotank_id
    @invoice.container_id = @invoice_ori.container_id

    respond_to :html
  end

    def isotank
        @where = "invoice_isotank"
        @date = params[:date]
        @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
        @invoices = Invoice.where("date = ?", @date.to_date).where("isotank_id != 0").order(:id)
    end

    def kereta
        @date = params[:date]
        @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
        @invoices = Invoice.where("date = ? and invoicetrain is true", @date.to_date).where(transporttype: "KERETA").order(:id)
    end

    def kapal
        @where = "invoice_kapal"
        @date = params[:date]
        @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
        @invoices = Invoice.where("date = ?", @date.to_date).where(transporttype: "KAPAL (TOL LAUT)").order(:id)
    end

  def updateinvoice
		
		puts '~~~~> update inv <~~~~'
		
    inputs = params[:invoice]
    @invoice = Invoice.new
    @invoice_ori = Invoice.find(inputs[:invoice_id])

    if inputs[:process] == 'create'
      @invoice = @invoice_ori.dup
  
      quantity = inputs[:quantity].to_i
      @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
			
			@vehicle = @invoice_ori.vehicle
			vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
			year_made = @vehicle.year_made.to_i if @vehicle
			year_diff = 0

			if !year_made.blank? && year_made.to_i > 1000
				year_diff = Date.current.year - year_made
			end
 
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
				
				puts "===> gas litre ori"
				puts gas_litre
				puts "===> year diff"
				puts year_diff
				
				if year_diff >= 15
					gas_litre += gas_litre.to_i * year_diff.to_i / 100
					puts "===> gas litre >= 15y"
					puts gas_litre
				end
				
        gas_allowance = gas_litre * @gascost
				
				puts "===> gas_allowance"
				puts gas_allowance
				
        ferry_fee = @route.ferry_fee
        tol_fee = quantity * @route.tol_fee
        total = gas_allowance + driver_allowance + misc_allowance + tol_fee + helper_allowance
				
				puts "===> total"
				puts total

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

  def updateaddweight

    inputs = params[:invoice]

    # render json: inputs

    @invoice = Invoice.find(inputs[:invoice_id])
    
    @invoice.load_date = inputs[:load_date]
    @invoice.weight_gross = inputs[:weight_gross] 

    if @invoice.save
      redirect_to("/invoices/add_weight/"+@invoice.id.to_s)
    end

  end

end

       

def fetch_excel
      s = Roo::Excel.new("./db/bkkkereta.xls") 

      s.default_sheet = s.sheets.first


      date = Date.today.strftime('01-05-%Y')

      # product = Product.all

      # product.each do |p|
      #   p.code = p.code.gsub ".0", ""
      #   p.save
      # end
      count = 0

      start = 7
      7.upto(56) do |line| #start and end of row

        if start == line
          date = s.cell(line,'B')
          cust_ = s.cell(line,'C').rstrip
          nopol_ = s.cell(line,'D').rstrip.lstrip
          driver_ = s.cell(line,'E').rstrip
          quantity = s.cell(line,'F').to_i
          isotank_ = s.cell(line,'G').rstrip
          route_ = s.cell(line,'H').rstrip.lstrip
          kernet_ = s.cell(line,'I').rstrip.lstrip
          office_ = s.cell(line,'J').rstrip.lstrip

          @need_helper = kernet_ == "OK" ? true : false
          @office = office_ == "SBY" ? 1 : 2

          @customer = Customer.where(:name => cust_).first
          @vehicle = Vehicle.where(:current_id => nopol_).first
          @driver = Driver.where(:name => driver_).first
          @isotanknumber = Isotank.where(:isotanknumber => isotank_).first
          @route = Route.where(:name => route_, :customer_id => @customer.id).first


          @invoice = Invoice.new
    
          gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance  = total = 0

          @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0

          @invoice.date = date
          @invoice.gas_cost = @gascost
          @invoice.quantity = quantity
          @invoice.vehicle_id = @vehicle.id
          @invoice.driver_id = @driver.id
          @invoice.vehiclegroup_id = @vehicle.vehiclegroup_id
          @invoice.need_helper = false
          @invoice.isotank_id = @isotanknumber.id
          @invoice.invoicetrain = true
          @invoice.customer_id = @customer.id
          @invoice.route_id = @route.id
          @invoice.price_per = @invoice.route.price_per || 0
          @invoice.insurance = 0
          @invoice.office_id = 1
          @invoice.driver_phone = @driver.mobile
          @invoice.need_helper = @need_helper
          @invoice.office_id = @office

          rate = Setting.find_by_name("Rate Asuransi").value.to_f rescue nil || 0
          @invoice.insurance_rate = rate
          @invoice.user_id = current_user.id

          @invoice.incentive = @invoice.vehicle.vehicleincentivegroup.incentive.to_f rescue 0
          
          @allowances = Allowance.where(:route_id => @route.id, :vehiclegroup_id => @vehicle.vehiclegroup_id, :deleted => false).first

          if !@allowances.nil?

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

          @invoice.save

          @invoice_parent = @invoice.id

          date = s.cell(line+1,'B')
          cust_ = s.cell(line+1,'C').rstrip
          nopol_ = s.cell(line+1,'D').rstrip.lstrip
          driver_ = s.cell(line+1,'E').rstrip
          quantity = s.cell(line+1,'F').to_i
          isotank_ = s.cell(line+1,'G').rstrip
          route_ = s.cell(line+1,'H').rstrip.lstrip
          kernet_ = s.cell(line,'I').rstrip.lstrip
          office_ = s.cell(line,'J').rstrip.lstrip

          @need_helper = kernet_ == "OK" ? true : false
          @office = office_ == "SBY" ? 1 : 2

          @customer = Customer.where(:name => cust_).first
          @vehicle = Vehicle.where(:current_id => nopol_).first
          @driver = Driver.where(:name => driver_).first
          @isotanknumber = Isotank.where(:isotanknumber => isotank_).first
          @route = Route.where(:name => route_, :customer_id => @customer.id).first


          @invoice = Invoice.new
    
          gas_litre = ferry_fee = tol_fee = gas_allowance = driver_allowance  = total = 0

          @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0

          @invoice.date = date
          @invoice.gas_cost = @gascost
          @invoice.quantity = quantity
          @invoice.vehicle_id = @vehicle.id
          @invoice.driver_id = @driver.id
          @invoice.vehiclegroup_id = @vehicle.vehiclegroup_id
          @invoice.need_helper = false
          @invoice.isotank_id = @isotanknumber.id
          @invoice.invoicetrain = true
          @invoice.customer_id = @customer.id
          @invoice.route_id = @route.id
          @invoice.price_per = @invoice.route.price_per || 0
          @invoice.insurance = 0
          @invoice.office_id = 1
          @invoice.driver_phone = @driver.mobile
          @invoice.invoice_id = @invoice_parent
          @invoice.need_helper = @need_helper
          @invoice.office_id = @office

          rate = Setting.find_by_name("Rate Asuransi").value.to_f rescue nil || 0
          @invoice.insurance_rate = rate
          @invoice.user_id = current_user.id

          @invoice.incentive = @invoice.vehicle.vehicleincentivegroup.incentive.to_f rescue 0
          
          @allowances = Allowance.where(:route_id => @route.id, :vehiclegroup_id => @vehicle.vehiclegroup_id, :deleted => false).first

          if !@allowances.nil?

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

          @invoice.save
          start += 3

        end
        
      end


      
    end
