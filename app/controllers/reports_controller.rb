class ReportsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section
  protect_from_forgery :except => [:ledger, :apibranchstats, :apibranchstatsbkk, :apibranchstatsbkkbreakdown]

  def set_section

  end

  def index
    redirect_to '/reports/expenses-daily'
  end

  def revenuebreakdown
    @customer_id = params[:customer_id].present? ? params[:customer_id] : nil
    @commodity_id = params[:commodity_id].present? ? params[:commodity_id] : nil
    @transporttype = params[:transporttype].present? ? params[:transporttype] : 'all'

    @month = params[:month]
    @month = "%02d" % Date.today.month.to_s if @month.nil?
    @year = params[:year]
    @year = Date.today.year if @year.nil?

    @monthEnd = params[:monthEnd]
    @monthEnd = "%02d" % Date.today.month.to_s if @monthEnd.nil?
    @dayEnd = getlastday (@monthEnd.to_s)
    @yearEnd = params[:yearEnd]
    @yearEnd = Date.today.year if @yearEnd.nil?

    @events = Event.active.where("start_date BETWEEN ? AND ?", "#{@year}-#{@month}-01","#{@yearEnd}-#{@monthEnd}-#{@dayEnd}")
    @events = @events.where("customer_id=?", @customer_id) if @customer_id.present?
    @events = @events.where("commodity_id=?", @commodity_id) if @commodity_id.present?

    if @transporttype.present? and @transporttype != 'all'
      if @transporttype == 'RORO'
        @events = @events.where('invoiceship = true')
      elsif @transporttype == 'LOSING'
        @events = @events.where('losing = true')
      else
        if @transporttype == 'KERETA'
          @events = @events.where('invoicetrain = true')
        else
          @events = @events.where('invoicetrain = false')
        end
      end
    end

  end

  def estimation
    role = cek_roles 'Admin Keuangan, Estimasi'
    if role
      offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      # @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @enddate = (Date.today).strftime('%d-%m-%Y') if @enddate.nil?
      @vehicles = Vehicle.order(:current_id).all

      @invoices = Invoice.where('date BETWEEN :startdate AND :enddate and deleted = false and id in (select invoice_id from receipts where deleted = false)', {:startdate => @startdate.to_date, :enddate => @enddate.to_date})

      @tanktype = params[:tanktype]
      if params[:tanktype].present? && params[:tanktype] != 'Semua'
        @vehicles = Vehicle.where('platform_type = ?', @tanktype)
        @invoices = @invoices.where('vehicle_id in (?)', @vehicles)
      end

      @vehicle_id = params[:vehicle_id]

      if params[:vehicle_id].present? && params[:vehicle_id] != 'all'
        @invoices = @invoices.where('vehicle_id = ?', @vehicle_id)
      end

      if params[:office_id].present?
        @invoices = @invoices.where(office_id: params[:office_id])
      end
      if params[:customer_id].present?
        @invoices = @invoices.where(customer_id: params[:customer_id])
      end
      @invoices = @invoices.order(:id)
      @ids = @invoices.any? ? @invoices.collect(&:id).join(",") : 0

      @receiptreturns = Receiptreturn.where("deleted = false AND invoice_id in (#{@ids})")

      # @receipts = Receipt.where("(created_at >= ? and created_at < ?) AND deleted = false", @startdate.to_date, @enddate.to_date + 1.day)
      # @countbkm = Receiptreturn.where("(created_at >= ? and created_at < ?) AND deleted = false", @startdate.to_date, @enddate.to_date + 1.day).count(:id)

      #update price
      @invoices.each do |invoice|
        invoice.price_per = invoice.route.price_per if !invoice.route_id.blank?
        invoice.save
      end

      @section = "estimationreport"
      @where = "estimation"
      @customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Acidatama.*'").pluck(:id)
      # render json: @customer_35

      render "estimation"
    else
      redirect_to root_path()
    end


  end

  def productstocks
    role = cek_roles 'Admin HRD, Admin Gudang'
    if role
      @products = Product.active.all(:order=>:name)
      @productgroups = Productgroup.active.order(:name)
      @section = "reports2"
      @where = "productstocks"
      render "productstocks"
    else
      redirect_to root_path()
    end

  end

  def downloadexcelproductstocks

    @date = Date.today.strftime('%d-%m-%Y')

    filename = "productstocks_" + @date.to_date.strftime('%d%m%Y') + ".xls"

    @productgroups = Productgroup.active.order(:name)

    green = Axlsx::Color.new :rgb => "FF00FF00"
    red = Axlsx::Color.new :rgb => "FFCC0033"

    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Kas Harian") do |sheet|

      bold = sheet.styles.add_style(:b => true)
      right = sheet.styles.add_style(:alignment => {:horizontal => :right})
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      h1 = sheet.styles.add_style :b => true, :sz => 16
      h2 = sheet.styles.add_style :b => true, :sz => 14
      h3_green = sheet.styles.add_style :color => green, :b => true
      h3_red = sheet.styles.add_style :color => red, :b => true
      number = sheet.styles.add_style :format_code => "#,##0.00"
      number_bold = sheet.styles.add_style :format_code => "#,##0.00", :b => true

      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

      sheet.add_row [''], :height => 20
      sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Stok Barang: " + @date.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

      sheet.add_row [''], :height => 20
      sheet.add_row ['','NO', 'NAMA BARANG', 'JUMLAH', 'HARGA', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, right_bold, right_bold, right_bold]

      @productgroups.each do |group|

        sheet.add_row [''], :height => 20
        sheet.add_row ['',group.name] , :height => 20, :style => [nil, h3_red]

        running = 0

        sheet.add_row [''], :height => 20
        group.products.active.order(:name).each_with_index do |product,i|
          sheet.add_row ['',i+1, product.name, product.stock, product.unit_price, product.stock * product.unit_price ] , :height => 20, :style => [nil, nil, nil, number, number, number]
          running += product.stock * product.unit_price
        end
        sheet.add_row ['','','TOTAL', '', '', running] , :height => 20, :style => [nil, nil, bold,  nil, nil, number_bold]

      end

      p.use_autowidth = false
      p.use_shared_strings = true

      send_data(p.to_stream.read, :filename => filename, :type => :xls, :x_sendfile => true)
    end
  end

  def paymentchecks
    role = cek_roles 'Admin Keuangan'
    if role
        @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @paymentchecks = Paymentcheck.where("date >= ? and date < ? AND deleted = false", @startdate.to_date, @enddate.to_date + 1.day).order(:supplier_id)

      @section = "reports2"
      @where = "paymentchecks"
      render "paymentchecks"
    else
      redirect_to root_path()
    end

  end

  def assets
    role = cek_roles 'Admin Keuangan'
    if role
      @month = params[:month]
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @balance = 0
      @assetlancars = Asset.where(:asset_type => 'Lancar')
      @assettaklancars = Asset.where(:asset_type => 'Tidak Lancar')
      @vehicles = Vehicle.where("date_purchase IS NOT NULL AND amount IS NOT NULL").order(:current_id)

      amountlancars = Asset.where(:asset_type => 'Lancar').sum(:amount)
      amounttaklancars = Asset.where(:asset_type => 'Tidak Lancar').sum(:amount)
      amountvehicle = Vehicle.sum(:amount)

      @balance = amountlancars + amounttaklancars + amountvehicle

      @section = "reports1"
      @where = "reports-assets"
      render "assets"
    else
      redirect_to root_path()
    end

  end

  def suppliers
    role = cek_roles 'Admin HRD, Admin Gudang'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      if params[:supplier_id] == "all"
        @suppliers = Supplier.all
      else
        @supplier = Supplier.find(params[:supplier_id]) rescue nil
      end

      @balance = 0

      @section = "reports2"
      @where = "suppliers"
      render "suppliers"
    else
      redirect_to root_path()
    end

  end

  def customers
    role = cek_roles 'Admin Keuangan, Admin Auditor, Admin Penagihan'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @customers = Customer.active.order(:name)

      @section = "reports2"
      @where = "reports-customers"
      render "customers"
    else
      redirect_to root_path()
    end

  end

  def customercredits
    role = cek_roles 'Admin Keuangan, Admin Auditor, Admin Penagihan'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @customers = Customer.active.order(:name)

      @section = "reports2"
      @where = "reports-customercredits"
      render "customercredits"
    else
      redirect_to root_path()
    end

  end

  def suppliercredits
    role = cek_roles 'Admin Keuangan, Admin Auditor'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @suppliers = Supplier.active.order(:name)

      @section = "reports2"
      @where = "reports-suppliercredits"
      render "suppliercredits"
    else
      redirect_to root_path()
    end

  end

  def tiretargets
    role = cek_roles 'Admin Keuangan, Admin Auditor'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @vehicles = Vehicle.where(:deleted => false).order(:current_id) rescue nil
      @productgroups = Productgroup.active.where(:tire_flag => true).order(:name) rescue nil

      @productgroup_id = params[:productgroup_id].nil? ? @productgroups.first.id : params[:productgroup_id].to_i

      # @suppliers = Supplier.active.order(:name)

      @section = "reports2"
      @where = "reports-tiretargets"
      render "tiretargets"
    else
      redirect_to root_path()
    end

  end

  def getcustomerdata
    @year = params[:year]
    @year = Date.today.year if @year.nil?

    objReturn = []
    objReturn2 = []

    @customers = Customer.active.order("name desc")
    @customers.each_with_index do |customer, i|
      cus_name = ''
      if customer.name.length > 20
        cus_name = getwords(customer.name, 20)
      else
        cus_name = customer.name
      end
      taxinvoices = Taxinvoice.where("extract(year from date) = #{@year} and paiddate is null and deleted = false and customer_id = #{customer.id}").sum(:total)
      objReturn[i] = [taxinvoices.to_i, cus_name]
    end

    objReturn2[0] = objReturn
    respond_to do |format|
      format.json {render :json => objReturn2 }
    end
  end

  def product_orders
    role = cek_roles 'Admin HRD, Admin Gudang'
    if role
      @productgroup_id = params[:productgroup_id]
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      if @productgroup_id
        if @productgroup_id.to_i > 0
          @productgroups = Productgroup.where(:id => @productgroup_id)
        else
          @productgroups = Productgroup.order(:name)
        end
      end

      @section = "reports2"
      @where = "product-orders"
      render "product-orders"
    else
      redirect_to root_path()
    end

  end

  def bonus_receipts
    role = cek_roles 'Admin HRD'
    if role
      @month = params[:month]
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      if params[:driver_id].nil? || params[:driver_id] == ""
        @bonusreceipts = Bonusreceipt.active.where("to_char(created_at, 'MM-YYYY') = ?", "#{@month}-#{@year}").order(:id)
      else
        @bonusreceipts = Bonusreceipt.active.joins(:invoice).where("to_char(bonusreceipts.created_at, 'MM-YYYY') = ?", "#{@month}-#{@year}")
                                                  .where("invoices.driver_id = #{params[:driver_id]}").order(:id)
      end

      if params[:driver_id].nil? || params[:driver_id] == ""
        @invpremis = Receipt.active.where("to_char(created_at, 'MM-YYYY') = ?", "#{@month}-#{@year}").where("money(premi_allowance) > money(0)").order(:id)
      else
        @invpremis = Receipt.active.joins(:invoice).where("to_char(receipts.created_at, 'MM-YYYY') = ?", "#{@month}-#{@year}")
                                                  .where("invoices.driver_id = #{params[:driver_id]}")
                                                  .where("money(premi_allowance) > money(0)").order(:id)
      end

      @driver = Driver.find(params[:driver_id]) rescue nil
      @driver_id = @driver.id if @driver

    else
      redirect_to root_path
    end

    @section = "reports1"
    @where = "bonus-receipts"
    render "bonus-receipts"
  end

  def incomes_vehicle
    role = cek_roles 'Admin Keuangan, Admin Operasional, Admin HRD'
    if role
        @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @income = 0

      @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
      if @vehicle

        @invoices = Invoice.active.where('date BETWEEN :startdate AND :enddate', {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).where(:vehicle_id => @vehicle.id)

        @inv_ids = @invoices.any? ? @invoices.collect(&:id).join(",") : 0

        @taxinvoiceitems = Taxinvoiceitem.active.joins(:taxinvoice)
                              .where(:taxinvoices => {:deleted => false})
                              .where("money(taxinvoiceitems.total) > money(0) and taxinvoiceitems.invoice_id IN (#{@inv_ids})")

                              # .find_by_sql("SELECT * FROM taxinvoiceitems WHERE money(total) > money(0) and invoice_id IN (SELECT id FROM invoices WHERE vehicle_id = #{@vehicle.id} AND (date >= '#{@startdate.to_date}'::date and date < '#{@enddate.to_date + 1.day}'::date))")

        @invoicechilds = Invoice.active.find_by_sql("SELECT id FROM invoices WHERE id IN (SELECT invoice_id FROM invoices where invoice_id IS NOT NULL and invoicetrain IS TRUE and vehicle_id = #{@vehicle.id} AND (date >= '#{@startdate.to_date}'::date and date < '#{@enddate.to_date + 1.day}'::date))")

        @ids = @invoicechilds.any? ? @invoicechilds.collect(&:id).join(",") : 0

        @taxinvoicetrains = Taxinvoiceitem.active.joins(:taxinvoice)
                              .where(:taxinvoices => {:deleted => false})
                              .where("money(taxinvoiceitems.total) > money(0) and taxinvoiceitems.invoice_id IN (#{@ids})")

        # @taxgenericitems = Taxgenericitem.active.find_by_sql("SELECT * FROM taxgenericitems WHERE money(total) > money(0) AND vehicle_id = #{@vehicle.id} AND (date >= '#{@startdate.to_date}'::date AND date < '#{@enddate.to_date + 1.day}'::date)")

        @taxgenericitems = Taxgenericitem.active.joins(:taxinvoice)
                            .where(:taxinvoices => {:deleted => false})
                            .where(:taxgenericitems => {:vehicle_id => @vehicle.id})
                            .where('taxgenericitems.date BETWEEN :startdate AND :enddate ', {:startdate => @startdate.to_date, :enddate => @enddate.to_date})

        # @taxinvoiceitems.each do |item|
        #   @income += item.total.to_i
        # end

        # taxinvoicetrains.each do |item|
        #   @income += item.total.to_i / 2
        # end

        # @taxgenericitems.each do |item|
        #   @income += item.total.to_i
        # end
      end

      @section = "reports2"
      @where = "incomes-vehicle"
      render "incomes-vehicle"
    else
      redirect_to root_path()
    end

  end

  def expenses_vehicle
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Gudang'
    
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @productgroups = Productgroup.active.order(:name)
      @officeexpensegroups = Officeexpensegroup.active.order(:name)
      @outcome = 0

      @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
      @driver = Driver.find(params[:driver_id]) rescue nil

      if @vehicle
        date_start = @startdate.to_date
        date_end   = @enddate.to_date + 1

        # Build invoice conditions
        invoice_conditions = ["vehicle_id = ?"]
        invoice_params = [@vehicle.id]

        if @driver
          invoice_conditions << "driver_id = ?"
          invoice_params << @driver.id
        end

        invoice_sql = invoice_conditions.join(" AND ")

        # Receipts
        @receipts = Receipt.where(
          "(created_at > ? AND created_at < ?) AND deleted = false AND invoice_id IN (
            SELECT id FROM invoices WHERE #{invoice_sql}
          )",
          date_start, date_end, *invoice_params
        ).order("created_at ASC")

        # Receipt Returns
        @receiptreturns = Receiptreturn.where(
          "invoice_id IN (
            SELECT r.invoice_id FROM receipts r
            INNER JOIN invoices i ON r.invoice_id = i.id
            WHERE r.created_at > ? AND r.created_at < ? AND r.deleted = false AND (#{invoice_sql})
          )",
          date_start, date_end, *invoice_params
        )

        # Solar Pomps
        @solar_pomps = Receipt.joins(:invoice).where(
          "receipts.created_at > ? AND receipts.created_at < ? AND receipts.deleted = false AND invoices.gas_voucher > 0 AND receipts.invoice_id IN (
            SELECT id FROM invoices WHERE #{invoice_sql}
          )",
          date_start, date_end, *invoice_params
        ).order("receipts.created_at ASC")

        # Receipt Expenses
        @receiptexpenses = Receiptexpense.where(
          "created_at >= ? AND created_at < ? AND deleted = false AND officeexpense_id IN (
            SELECT id FROM officeexpenses WHERE vehicle_id = ?
          )",
          date_start, date_end, @vehicle.id
        ).order("created_at ASC")

        # unused
        @receiptpremis = Receiptpremi.where("(created_at >= ? and created_at < ?) AND deleted = false AND invoice_id IN (SELECT id FROM invoices WHERE vehicle_id = ?)", @startdate.to_date, @enddate.to_date + 1.day, @vehicle.id).order(:created_at) rescue nil
        @receiptincentives = Receiptincentive.where("(created_at >= ? and created_at < ?) AND deleted = false AND invoice_id IN (SELECT id FROM invoices WHERE vehicle_id = ?)", @startdate.to_date, @enddate.to_date + 1.day, @vehicle.id).order(:created_at) rescue nil
        @productrequestitems = Productrequestitem.where("productrequest_id in (SELECT id from productrequests where(date >= ? and date < ?) AND deleted = false AND vehicle_id = ?)", @startdate.to_date, @enddate.to_date + 1.day, @vehicle.id)
        @productrequests = Productrequest.where("(date >= ? and date < ?) AND deleted = false AND vehicle_id = ?", @startdate.to_date, @enddate.to_date + 1.day, @vehicle.id).order(:date) rescue nil

        @outcome = @receipts.sum(:total).to_i - @receiptreturns.sum(:total).to_i  + @receiptpremis.sum(:total).to_i + @receiptincentives.sum(:total).to_i + @receiptexpenses.where(:expensetype => 'Kredit').sum(:total).to_i - @receiptexpenses.where(:expensetype => 'Debit').sum(:total).to_i + @productrequestitems.sum(:total).to_i
      end

      @section = "reports2"
      @where = "expenses-vehicle"
      render "expenses-vehicle"
    else
      redirect_to root_path()
    end

  end

  def taxinvoices_report
    role = current_user.owner
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @taxinvoices = Taxinvoice.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order(:date)

      @section = "reports1"
      @where = "taxinvoices-report"
      render "taxinvoices-report"
    else
      redirect_to root_path()
    end

  end

  def taxinvoiceitems_report
    role = cek_roles 'Admin Operasional, Admin Keuangan, Vendor Supir'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @customer_id = Customer.find(params[:customer_id]).id rescue nil

      if @customer_id
        @taxinvoiceitems = Taxinvoiceitem.active.where("(taxinvoiceitems.date >= ? and taxinvoiceitems.date < ? AND taxinvoiceitems.customer_id = ?)", @startdate.to_date, @enddate.to_date + 1, @customer_id).order("taxinvoiceitems.date, taxinvoiceitems.taxinvoice_id")
      else
        @taxinvoiceitems = Taxinvoiceitem.active.where("(taxinvoiceitems.date >= ? and taxinvoiceitems.date < ?)", @startdate.to_date, @enddate.to_date + 1).order("taxinvoiceitems.date ASC, taxinvoiceitems.taxinvoice_id ASC")
      end

      @event_id = Event.find(params[:event_id]).id rescue nil

      if @event_id
        @taxinvoiceitems = @taxinvoiceitems.joins(:invoice).where("event_id = ? ", @event_id)
      end

      if checkroleonly 'Vendor Supir'

        @vendor = Vendor.where('user_id = ?', current_user.id)

        if @vendor.present?
          @drivers = Driver.order('name')
          @drivers = @drivers.where("vendor_id = ?", @vendor[0].id)

          @taxinvoiceitems = @taxinvoiceitems.joins(:invoice).where("invoices.driver_id in (select id from drivers where vendor_id = ?)", @vendor[0].id)
        end

      end

      @section = "reports1"
      @where = "taxinvoiceitems-report"
      render "taxinvoiceitems-report"
    else
      redirect_to root_path()
    end

  end

  def taxinvoiceitems_upload_report
    role = cek_roles 'Admin Operasional, Admin Keuangan, Vendor Supir'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @customer_id = Customer.find(params[:customer_id]).id rescue nil

      if @customer_id
        @taxinvoiceitems = Taxinvoiceitem.active.where("(taxinvoiceitems.date >= ? and taxinvoiceitems.date < ? AND taxinvoiceitems.customer_id = ?)", @startdate.to_date, @enddate.to_date + 1, @customer_id).order("taxinvoiceitems.date, taxinvoiceitems.invoice_id")
      else
        @taxinvoiceitems = Taxinvoiceitem.active.where("(taxinvoiceitems.date >= ? and taxinvoiceitems.date < ?)", @startdate.to_date, @enddate.to_date + 1).order("taxinvoiceitems.date ASC, taxinvoiceitems.invoice_id ASC")
      end

      @event_id = Event.find(params[:event_id]).id rescue nil

      if @event_id
        @taxinvoiceitems = @taxinvoiceitems.joins(:invoice).where("event_id = ? ", @event_id)
      end

      @section = "reports1"
      @where = "taxinvoiceitems-upload-report"
      render "taxinvoiceitems-upload-report"
    else
      redirect_to root_path()
    end

  end

  def isotanks_report
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Gudang'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      if params[:transporttype].present?

        if params[:transporttype] == 'KERETA'
          @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND invoicetrain = true AND tanktype = 'ISOTANK' AND isotank_id is not null)", @startdate.to_date, @enddate.to_date + 1).order(:date)
        else
          @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND invoicetrain = false AND tanktype = 'ISOTANK' AND isotank_id is not null)", @startdate.to_date, @enddate.to_date + 1).order(:date)
        end

      else

        @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND tanktype = 'ISOTANK' AND isotank_id is not null)", @startdate.to_date, @enddate.to_date + 1).order(:date)

      end

      @invoices = @invoices.where(isotank_id: params[:isotank_id]) if params[:isotank_id].present?

      @section = "reports1"
      @where = "isotanks-report"
      render "isotanks-report"
    else
      redirect_to root_path()
    end

  end

  def isotankutilization
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Gudang'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @isotanks = Isotank.active.order(:isotanknumber)
      @isotanks = @isotanks.where("isotanknumber IN ('NLLU 2902068','NLLU 2902073','NLLU 2902089','NLLU 2902094','NLLU 2902108','NLLU 2902113','NLLU 2902129','NLLU 2902134','NLLU 2902140','NLLU 2902155','NLLU 2902284','NLLU 2902290','NLLU 2902303','NLLU 2902319','NLLU 2902324','NLLU 2902330','NLLU 2902345','NLLU 2902350','NLLU 2902366','NLLU 2902371','NLLU 2900764','NLLU 2900770','NLLU 2900785','NLLU 2900790','NLLU 2900804','NLLU 2900810','NLLU 2900825','NLLU 2900830','NLLU 2900846','NLLU 2900851','NLLU 2901380','NLLU 2901415','NLLU 2901800','NLLU 2901816','NLLU 2901842','NLLU 2901159','NLLU 2901190','NLLU 2901210','NLLU 2901225','NLLU 9700027','NLLU 2800277','NLLU 2800282','NLLU 2800298','SAXU 2705112','SAXU 2705468','NLLU 2900907','NLLU 2900912','NLLU 2900928','NLLU 2900949','NLLU 2901077','NLLU 2901082','NLLU 2901117','NLLU 2901122','NLLU 2901138','NLLU 2901164','NLLU 2902746','NLLU 2902751','NLLU 2902767','NLLU 2902772','NLLU 2902788','NLLU 2902793','NLLU 2902807','NLLU 2902812','NLLU 2902828','NLLU 2902833','NLLU 2902849','NLLU 2902854','NLLU 2902860','NLLU 2902875','NLLU 2900070','NLLU 2900105','NLLU 2900173','NLLU 2900189','NLLU 2900424','NLLU 2900430')")
      # @isotanks = Isotank.active.order(:isotanknumber)
      @section = "reports1"
      @where = "isotanks-utilization"
      render "isotankutilization"
    else
      redirect_to root_path()
    end

  end

  def containers_report
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Gudang'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND invoicetrain = false AND tanktype = 'KONTAINER' AND (container_id is not null AND container_id != 0))", @startdate.to_date, @enddate.to_date + 1).order(:date)

      if params[:transporttype].present?

        if params[:transporttype] == 'KERETA'
          @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND invoicetrain = true AND tanktype = 'KONTAINER' AND (container_id is not null AND container_id != 0))", @startdate.to_date, @enddate.to_date + 1).order(:date)
          if params[:category].present?
            @invoices = @invoices.where("container_id in (select id from containers where category = ?)", params[:category])
          end
        else
          @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND invoicetrain = false AND tanktype = 'KONTAINER' AND (container_id is not null AND container_id != 0))", @startdate.to_date, @enddate.to_date + 1).order(:date)
          if params[:category].present?
            @invoices = @invoices.where("container_id in (select id from containers where category = ?)", params[:category])
          end
        end

      else

        @invoices = Invoice.active.where("(date >= ? and date < ? AND deleted = false AND tanktype = 'KONTAINER' AND (container_id is not null AND container_id != 0))", @startdate.to_date, @enddate.to_date + 1).order(:date)
        if params[:category].present?
          @invoices = @invoices.where("container_id in (select id from containers where category = ?)", params[:category])
        end

      end

        # @invoices = @invoices.where(container_id: params[:container_id]) if params[:container_id].present?



      @section = "reports1"
      @where = "containers-report"
      render "containers-report"
    else
      redirect_to root_path()
    end

  end

  def containerutilization
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Gudang'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @containers = Container.active.order(:containernumber)
      # @isotanks = Isotank.active.order(:isotanknumber)
      @section = "reports1"
      @where = "containers-utilization"
      render "containerutilization"
    else
      redirect_to root_path()
    end

  end

  def invoices
    role = cek_roles 'Admin Operasional, Admin Keuangan'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @transporttype = params[:transporttype]
      @invoices = Invoice.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")
      @invoicereturns = Invoicereturn.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")

      if @transporttype == 'KERETA'

        @invoices = @invoices.where("invoicetrain = true")

      elsif @transporttype == 'TRUK'

        @invoices = @invoices.where("invoicetrain = false")

      end

      @section = "reports1"
      @where = "report_invoices"
      render "invoices"
    else
      redirect_to root_path()
    end
  end

def confirmed_invoices
    role = cek_roles 'Admin Operasional, Admin Keuangan, Vendor Supir, Admin Penagihan'
    if role
      @offices = Office.active
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @transporttype = params[:transporttype]
      @invoices = Invoice.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")
      @invoicereturns = Invoicereturn.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")

      @drivers = Driver.active.order('name')
      @driver_id = params[:driver_id]

      if checkroleonly 'Vendor Supir'

        @vendor = Vendor.where('user_id = ?', current_user.id)

        if @vendor.present?
          @drivers = Driver.order('name')
          @drivers = @drivers.where("vendor_id = ?", @vendor[0].id)

          @invoices = @invoices.where("driver_id in (select id from drivers where vendor_id = ?)", @vendor[0].id)
        end

      end

      @vehicle_id = params[:vehicle_id]

      @office_id = params[:office_id]
      @is_premi = params[:is_premi]

      if @office_id.present? and @office_id != "all"
        @invoices = @invoices.where("office_id = ?", @office_id)
      end

      if @driver_id.present? and @driver_id != "all"
        @invoices = @invoices.where("driver_id = ?", @driver_id)
      end

      if @vehicle_id.present? and @vehicle_id != "all"
        @invoices = @invoices.where("vehicle_id = ?", @vehicle_id)
      end

      if @transporttype == 'KERETA'

        @invoices = @invoices.where("invoicetrain = true")

      elsif @transporttype == 'KOSONGAN'

        cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
        @invoices = @invoices.where("customer_id IN (?)", cust_kosongan).order(:id)

      elsif @transporttype == 'STANDART'

        cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
        @invoices = @invoices.where("invoicetrain = false").where("customer_id NOT IN (?)", cust_kosongan).order(:id)

      end

      @invoices = @invoices.where("id in (select invoice_id from receipts where deleted = false) AND id not in(select invoice_id from receiptreturns where deleted = false)")

      if @is_premi.present?

        if @is_premi == '1'

          @invoices = @invoices.where("premi_allowance > money(0)")

        elsif @is_premi == '0'

          @invoices = @invoices.where("premi = false")

        end

      end

      @section = "reports1"
      @where = "confirmed-invoices"
      render "confirmed_invoices"
    else
      redirect_to root_path()
    end
end

def confirmed_latest_invoices
    role = cek_roles 'Admin Operasional, Admin Keuangan, Vendor Supir, Admin Penagihan'
    if role
      @offices = Office.active
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @transporttype = params[:transporttype]

      @invoices = Invoice.active
                        .joins(:driver) # Join the drivers table
                        .where("(invoices.date >= ? and invoices.date < ?)", @startdate.to_date, @enddate.to_date + 1)
                        .select("DISTINCT ON (invoices.driver_id) invoices.*, drivers.name AS driver_name") # Select all invoice columns + driver name
                        .order("invoices.driver_id, invoices.date DESC, invoices.created_at DESC") # Order for DISTINCT ON


      @invoicereturns = Invoicereturn.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")

      @drivers = Driver.active.order('name')
      @driver_id = params[:driver_id]

      if checkroleonly 'Vendor Supir'

        @vendor = Vendor.where('user_id = ?', current_user.id)

        if @vendor.present?
          @drivers = Driver.order('name')
          @drivers = @drivers.where("vendor_id = ?", @vendor[0].id)

          @invoices = @invoices.where("driver_id in (select invoices.id from drivers where vendor_id = ?)", @vendor[0].id)
        end

      end

      @vehicle_id = params[:vehicle_id]

      @office_id = params[:office_id]
      @is_premi = params[:is_premi]

      if @office_id.present? and @office_id != "all"
        @invoices = @invoices.where("invoices.office_id = ?", @office_id)
      end

      if @driver_id.present? and @driver_id != "all"
        @invoices = @invoices.where("invoices.driver_id = ?", @driver_id)
      end

      if @vehicle_id.present? and @vehicle_id != "all"
        @invoices = @invoices.where("invoices.vehicle_id = ?", @vehicle_id)
      end

      if @transporttype == 'KERETA'

        @invoices = @invoices.where("invoicetrain = true")

      elsif @transporttype == 'KOSONGAN'

        cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
        @invoices = @invoices.where("customer_id IN (?)", cust_kosongan).order(:id)

      elsif @transporttype == 'STANDART'

        cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
        @invoices = @invoices.where("invoicetrain = false").where("customer_id NOT IN (?)", cust_kosongan).order(:id)

      end

      @invoices = @invoices.where("invoices.id in (select invoice_id from receipts where deleted = false) AND invoices.id not in(select invoice_id from receiptreturns where deleted = false)")

      if @is_premi.present?

        if @is_premi == '1'

          @invoices = @invoices.where("premi_allowance > money(0)")

        elsif @is_premi == '0'

          @invoices = @invoices.where("premi = false")

        end

      end

      @invoices = @invoices.sort_by { |invoice| invoice.driver_name || invoice.driver.name } # Use driver_name from select or association

      @section = "reports1"
      @where = "confirmed-latest-invoices"
      render "confirmed_latest_invoices"
    else
      redirect_to root_path()
    end
end

def collectible_invoices
  role = cek_roles 'Admin Operasional, Admin Keuangan, Vendor Supir, Admin Penagihan'
  if role

    @offices = Office.active
    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
    @transporttype = params[:transporttype]
    @invoices = Invoice.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")
    @invoicereturns = Invoicereturn.active.where("(date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order("created_at ASC")

    @drivers = Driver.active.order('name')
    @driver_id = params[:driver_id]

    if checkroleonly 'Vendor Supir'

      @vendor = Vendor.where('user_id = ?', current_user.id)

      if @vendor.present?
        @drivers = Driver.order('name')
        @drivers = @drivers.where("vendor_id = ?", @vendor[0].id)

        @invoices = @invoices.where("driver_id in (select id from drivers where vendor_id = ?)", @vendor[0].id)
      end

    end

    @vehicle_id = params[:vehicle_id]

    @office_id = params[:office_id]
    @is_premi = params[:is_premi]

    if @office_id.present? and @office_id != "all"
      @invoices = @invoices.where("office_id = ?", @office_id)
    end

    if @driver_id.present? and @driver_id != "all"
      @invoices = @invoices.where("driver_id = ?", @driver_id)
    end

    if @vehicle_id.present? and @vehicle_id != "all"
      @invoices = @invoices.where("vehicle_id = ?", @vehicle_id)
    end

    if @transporttype == 'KERETA'

      @invoices = @invoices.where("invoicetrain = true")

    elsif @transporttype == 'KOSONGAN'

      cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
      @invoices = @invoices.where("customer_id IN (?)", cust_kosongan).order(:id)

    elsif @transporttype == 'STANDART'

      cust_kosongan = Customer.active.where("name ~* '.*PURA.*' or name ~* '.*RDPI.*' or name ~* '.*RAJAWALI INTI.*'").pluck(:id)
      @invoices = @invoices.where("invoicetrain = false").where("customer_id NOT IN (?)", cust_kosongan).order(:id)

    end

    @invoices = @invoices.where("id in (select invoice_id from receipts where deleted = false) AND id not in(select invoice_id from receiptreturns where deleted = false)")
    @invoices = @invoices.where("id in (select taxinvoiceitems.invoice_id from taxinvoiceitems where taxinvoiceitems.deleted = false AND taxinvoiceitems.taxinvoice_id IS NOT NULL)")

    if @is_premi.present?

      if @is_premi == '1'

        @invoices = @invoices.where("premi_allowance > money(0)")

      elsif @is_premi == '0'

        @invoices = @invoices.where("premi = false")

      end

    end

    @section = "reports1"
    @where = "collectible-invoices"
    render "collectible_invoices"
  else
    redirect_to root_path()
  end
end


def drivervehicles
  role = cek_roles 'Admin Operasional, Admin Keuangan, Vendor Supir'
  if role

    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

    @drivers = Driver.active.order('name')

    if checkroleonly 'Vendor Supir'

      @vendor = Vendor.where('user_id = ?', current_user.id)

      if @vendor.present?
        @drivers = Driver.order('name')
        @drivers = @drivers.where("vendor_id = ?", @vendor[0].id)
      end

    end

    @driver_id = params[:driver_id]
    @driver = Driver.find(@driver_id) rescue nil

    if @driver

      @reports = Invoice.active.joins(:driver).joins(:vehicle).where("invoices.id in (select invoice_id from receipts where deleted = false)")
      .where("invoices.id not in (select invoice_id from receiptreturns where deleted = false)")
      .where("invoices.date between ? and ?",@startdate.to_date, @enddate.to_date).where("drivers.deleted = false")
      .where("invoices.driver_id = ?", @driver_id)
      .group("vehicles.id")
      .select("vehicles.id, vehicles.current_id, count(invoices.vehicle_id) as jml")
      .order('vehicles.current_id')

    end

    @section = "reports1"
    @where = "drivervehicles"
    render "drivervehicles"
  else
    redirect_to root_path()
  end
end

  def indexannualreport_vehicle
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Keuangan'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      params[:vehiclegroup_id] = 1 if params[:vehiclegroup_id].nil?

      @vehiclegroups= Vehiclegroup.where(:deleted => false).order(:id)
      @vehiclegroup = Vehiclegroup.find(params[:vehiclegroup_id]) rescue nil
      @vehiclegroup_id = @vehiclegroup.id if !@vehiclegroup.nil?

      # if @vehiclegroup.nil?
      #   @vehicles = Vehicle.active.all(:order=>:current_id).where(:vehiclegroup_id => 1)
      # else
      #   @vehicles = Vehicle.active.all(:order=>:current_id).where(:vehiclegroup_id => 1)
      # end
      @section = "reports2"
      @where = "annualreport-vehicle"
      render "indexannualreport-vehicle"
    else
      redirect_to root_path()
    end

  end

  def annualreport_vehicle
    @year = params[:year]
    @year = Date.today.year if @year.nil?
    @vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
    @vehicle_id = @vehicle.id if !@vehicle.nil?

    @officeexpensegroups = Officeexpensegroup.all(:order => :name)
    @productgroups = Productgroup.all(:order => :name)

    if @vehicle
      @receipts = Receipt.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{@vehicle_id})")
    end

    @section = "reports2"
    @where = "annualreport-vehicle"
    render "annualreport-vehicle"
  end

  def incomes_cashinout_perc
    role = cek_roles 'Admin Keuangan'

    if role
      @groupumum = Officeexpensegroup.where("officeexpensegroup_id=1 AND deleted=false").order(:id)
      @groupkantor = Officeexpensegroup.where("officeexpensegroup_id=5 AND deleted=false").order(:id)

      @year = params[:year]
      @year = Date.today.year if @year.nil?

    #   @month = params[:month]
    #   @month = "%02d" % Date.today.month.to_s if @month.nil?
    #   @year = params[:year]
    #   @year = Date.today.year if @year.nil?


    #   @groupumum = Officeexpensegroup.where("officeexpensegroup_id=1 AND deleted=false").order(:id)
    #   @groupkantor = Officeexpensegroup.where("officeexpensegroup_id=5 AND deleted=false").order(:id)




    # #Perhitungan SAlDO AWAL
    #   @balance, @incomes, @outcomes = 0 ,0 ,0

    #   #administrasi kantor
    #   administrasi = 0
    #   @groupkantor.each do |group|
    #     outcomegroupcredit = group.receiptexpenses.where("expensetype = 'Kredit' and deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}").sum(:total)
    #        outcomegroupdebit = group.receiptexpenses.where("expensetype = 'Debit' and deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}").sum(:total)
    #        outcomegrouptotal = outcomegroupcredit - outcomegroupdebit
    #        administrasi += outcomegrouptotal
    #     end

    #   #administrasi operasional
    #   operasional = 0
    #   @groupumum.each do |group|
    #     outcomegroupcredit = group.receiptexpenses.where("expensetype = 'Kredit' and deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}").sum(:total)
    #       if group.id == 8
    #         premi = Receiptpremi.where("deleted = false and to_char(created_at, 'MM-YYYY') = ?", "#{@month}-#{@year}").sum(:total)
    #         outcomegroupcredit += premi
    #       end
    #       outcomegroupdebet = group.receiptexpenses.where("expensetype = 'Debit' and deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}").sum(:total)
    #         outcomegrouptotal = outcomegroupcredit - outcomegroupdebet
    #         operasional +=  outcomegrouptotal
    #   end


    #   @incomeexpensebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                           FROM bankexpensegroups a
    #                                           LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY') ='#{@month}-#{@year}'
    #                                           WHERE a.ID IN (6,21) AND a.deleted = false
    #                                           GROUP BY a.id, a.name
    #                                           ORDER BY a.id")
    #   @incomeexpensebefore.each do |incomeexpense|
    #     @incomes += incomeexpense.total
    #   end

    #   @debtincomebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                           FROM bankexpensegroups a
    #                                           LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                           WHERE a.name like 'Hutang Direksi%' AND a.deleted = false
    #                                           GROUP BY a.id, a.name
    #                                           ORDER BY a.id")
    #   @debtincomebefore.each do |incomeexpense|
    #     @incomes += incomeexpense.total
    #   end

    #   @creditincomebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                     FROM bankexpensegroups a
    #                                     LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                     WHERE a.ID IN (112) AND a.deleted = false
    #                                     GROUP BY a.id, a.name
    #                                     ORDER BY a.id")
    #   @creditincomebefore.each do |incomeexpense|
    #     @incomes += incomeexpense.total
    #   end

    #   @assetsalebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                     FROM bankexpensegroups a
    #                                     LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                     WHERE a.ID IN (89) AND a.deleted = false
    #                                     GROUP BY a.id, a.name
    #                                     ORDER BY a.id")
    #   @assetsalebefore.each do |incomeexpense|
    #     @incomes += incomeexpense.total
    #   end

    #   @kmkfacilitiebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                     FROM bankexpensegroups a
    #                                     LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                     WHERE a.name like 'Fasilitas KMK%' AND a.deleted = false AND b.description like 'Pindah%'
    #                                     GROUP BY a.id, a.name
    #                                     ORDER BY a.id")
    #   @kmkfacilitiebefore.each do |incomeexpense|
    #     @incomes += incomeexpense.total
    #   end

    #   @bankexpensebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                           FROM bankexpensegroups a
    #                                           LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                           WHERE a.name like 'Biaya%' AND a.deleted = false
    #                                           GROUP BY a.id, a.name
    #                                           ORDER BY a.id")
    #   @bankexpensebefore.each do |outcome|
    #     @outcomes -= outcome.total
    #   end

    #   @capitalexpensebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                           FROM bankexpensegroups a
    #                                           LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                           WHERE a.name like 'Modal%' AND a.deleted = false
    #                                           GROUP BY a.id, a.name
    #                                           ORDER BY a.id")
    #   @capitalexpensebefore.each do |outcome|
    #     @outcomes -= outcome.total
    #   end

    #   @debtexpensebefore = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
    #                                           FROM bankexpensegroups a
    #                                           LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')<'#{@month}-#{@year}'
    #                                           WHERE a.name like 'Hutang%' AND a.deleted = false
    #                                           GROUP BY a.id, a.name
    #                                           ORDER BY a.id")
    #   @debtexpensebefore.each do |outcome|
    #     @outcomes -= outcome.total
    #   end

    #   @receiptpayrollsupirbefore = Receiptpayroll.joins(:payroll)
    #   .where("to_char(receiptpayrolls.created_at, 'MM-YYYY')<'#{@month}-#{@year}' AND receiptpayrolls.deleted = false")
    #   .where("payrolls.driver_id IS NOT NULL")

    #   @receiptpayrollkernetbefore = Receiptpayroll.joins(:payroll)
    #   .where("to_char(receiptpayrolls.created_at, 'MM-YYYY')<'#{@month}-#{@year}' AND receiptpayrolls.deleted = false")
    #   .where("payrolls.driver_id IS NULL")

    #   #OPERASIONAL SANGU
    #   @receiptbefore = Receipt.where("deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}")
    #   @receiptreturnbefore = Receiptreturn.where("deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}")
    #       #sangu
    #       @operasionalbefore = @receiptbefore.sum("driver_allowance + helper_allowance + gas_allowance + misc_allowance + tol_fee + ferry_fee").to_i - @receiptbefore.sum("driver_allowance + helper_allowance + gas_allowance + misc_allowance + tol_fee").to_i

    #       #office
    #   officeumumcredit = Receiptexpense.where("expensetype = 'Kredit' and officeexpensegroup_id = 1 and deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}").sum(:total)
    #   officeumumdebit = Receiptexpense.where("expensetype = 'Debit' and officeexpensegroup_id = 1 and deleted = false and to_char(created_at, 'MM-YYYY') < ?", "#{@month}-#{@year}").sum(:total)
    #       @officetotalbefore = officeumumcredit - officeumumdebit
    #   #=================

    #   #BEBAN OPERASIONAL DAN LAIN-LAIN
    #   @productrequestitembefore = Productrequestitem.where("productrequest_id in (select id from productrequests where vehicle_id is NULL AND deleted = false and to_char(date, 'MM-YYYY') < ?)", "#{@month}-#{@year}").sum(:total)


    #   @balance = @incomes - @outcomes - @operasionalbefore.to_i - @officetotalbefore.to_i - @receiptpayrollsupir.sum(:total) - @receiptpayrollkernet.sum(:total) - @productrequestitembefore - administrasi - operasional

      @section = "reports1"
      @where = "incomes-cashinout"
      render "incomes-cashinout"
    else
      redirect_to root_path()
    end

  end

  def incomes_cashinout
    role = cek_roles 'Admin Keuangan'
    @month = params[:month]

    if role
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @groupumum = Officeexpensegroup.where("officeexpensegroup_id=1 AND deleted=false").order(:id)
      @groupkantor = Officeexpensegroup.where("officeexpensegroup_id=5 AND deleted=false").order(:id)


      if @month == "0"
        @incomeexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE a.ID IN (6) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @debtincomes = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE (a.name like 'Hutang Direksi%' OR a.ID IN (21)) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @creditincomes = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                          FROM bankexpensegroups a
                                          LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                          WHERE a.ID IN (112) AND a.deleted = false AND b.deleted = false
                                          GROUP BY a.id, a.name
                                          ORDER BY a.id")

        @creditPura = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE a.ID IN (101) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")
        @creditInti = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE (a.name like 'Piutang Rajawali Inti%' OR a.ID IN (153)) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @assetsales = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                          FROM bankexpensegroups a
                                          LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                          WHERE a.ID IN (89) AND a.deleted = false AND b.deleted = false
                                          GROUP BY a.id, a.name
                                          ORDER BY a.id")

        @kmkfacilities = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                          FROM bankexpensegroups a
                                          LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                          WHERE a.name like 'Fasilitas KMK%' AND a.deleted = false AND b.deleted = false AND b.description like 'Pindah%'
                                          GROUP BY a.id, a.name
                                          ORDER BY a.id")

        @bankexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE a.name like 'Biaya%' AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @capitalexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE a.name like 'Modal%' AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @debtexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                                WHERE a.name like 'Hutang%' AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")


        @receiptpayrollsupir = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'YYYY')='#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NOT NULL")

        @receiptpayrollkernet = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'YYYY')='#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NULL")
      else

        @current = ""+@year.to_s+"-"+@month.to_s + "-01"
        @three_month_before = @current.to_date.end_of_month - 4.months

        @invoice_incomes = Taxinvoice.active.where("date BETWEEN :startdate AND :enddate", {:startdate => @three_month_before.to_date.at_beginning_of_month, :enddate => @three_month_before})


        @incomeexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE a.ID IN (6) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @debtincomes = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE (a.name like 'Hutang Direksi%' OR a.ID IN (21)) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @creditincomes = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                          FROM bankexpensegroups a
                                          LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                          WHERE a.ID IN (112) AND a.deleted = false AND b.deleted = false
                                          GROUP BY a.id, a.name
                                          ORDER BY a.id")

        @creditPura = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE a.ID IN (101) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")
        @creditInti = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE (a.name like 'Piutang Rajawali Inti%' OR a.ID IN (153)) AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @assetsales = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                          FROM bankexpensegroups a
                                          LEFT OUTER JOIN bankexpenses b on b.creditgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                          WHERE a.ID IN (89) AND a.deleted = false AND b.deleted = false
                                          GROUP BY a.id, a.name
                                          ORDER BY a.id")

        @kmkfacilities = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                          FROM bankexpensegroups a
                                          LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                          WHERE a.name like 'Fasilitas KMK%' AND a.deleted = false AND b.deleted = false AND b.description like 'Pindah%'
                                          GROUP BY a.id, a.name
                                          ORDER BY a.id")

        @bankexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE a.name like 'Biaya%' AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @capitalexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE a.name like 'Modal%' AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")

        @debtexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                                FROM bankexpensegroups a
                                                LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                                WHERE a.name like 'Hutang%' AND a.deleted = false AND b.deleted = false
                                                GROUP BY a.id, a.name
                                                ORDER BY a.id")


        @receiptpayrollsupir = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'MM-YYYY')='#{@month}-#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NOT NULL")

        @receiptpayrollkernet = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'MM-YYYY')='#{@month}-#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NULL")
      end

      @section = "reports1"
      @where = "incomes-cashinout"
      render "incomes_cashinout"
    else
      redirect_to root_path()
    end

  end

  def incomes_statement
    role = cek_roles 'Admin Keuangan'
    @month = params[:month]

    if role
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @groupumum = Officeexpensegroup.where("officeexpensegroup_id=1 AND deleted=false").order(:id)
      @groupkantor = Officeexpensegroup.where("officeexpensegroup_id=5 AND deleted=false").order(:id)

      if @month == "0"
        @bankexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                              FROM bankexpensegroups a
                                              LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                              WHERE a.name like 'Biaya%' AND a.deleted = false
                                              GROUP BY a.id, a.name
                                              ORDER BY a.id")

        @receiptpayrollsupir = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'YYYY')='#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NOT NULL")

        @receiptpayrollkernet = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'YYYY')='#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NULL")

      else
        @bankexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                              FROM bankexpensegroups a
                                              LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                              WHERE a.name like 'Biaya%' AND a.deleted = false
                                              GROUP BY a.id, a.name
                                              ORDER BY a.id")

        @receiptpayrollsupir = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'MM-YYYY')='#{@month}-#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NOT NULL")

        @receiptpayrollkernet = Receiptpayroll.joins(:payroll)
        .where("to_char(receiptpayrolls.created_at, 'MM-YYYY')='#{@month}-#{@year}' AND receiptpayrolls.deleted = false")
        .where("payrolls.driver_id IS NULL")

      end

      @section = "reports1"
      @where = "incomes-statement"
      render "incomes-statement"
    else
      redirect_to root_path()
    end

  end

  def incomes_statement_nocharge
    role = cek_roles 'Admin Keuangan'
    @month = params[:month]

    if role
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @groupumum = Officeexpensegroup.where("officeexpensegroup_id=1 AND name NOT LIKE 'Biaya%'")
      @groupkantor = Officeexpensegroup.where("officeexpensegroup_id=5 AND name NOT LIKE 'Biaya%'")

      if @month == "0"
        @bankexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                        FROM bankexpensegroups a
                                        LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'YYYY')='#{@year}'
                                        WHERE a.name not like 'Biaya%'
                                        GROUP BY a.id, a.name
                                        ORDER BY a.id")
      else
        @bankexpense = Bankexpense.find_by_sql("SELECT a.id, a.name, coalesce(sum(money(b.total)), money(0)) as total
                                        FROM bankexpensegroups a
                                        LEFT OUTER JOIN bankexpenses b on b.debitgroup_id=a.id and to_char(b.date, 'MM-YYYY')='#{@month}-#{@year}'
                                        WHERE a.name not like 'Biaya%'
                                        GROUP BY a.id, a.name
                                        ORDER BY a.id")
      end

      @section = "reports1"
      @where = "incomes-statement-nocharge"
      render "incomes-statement-nocharge"
    else
      redirect_to root_path()
    end

  end

  def expenses_daily
    role = cek_roles 'Admin Keuangan, Admin Operasional'
    if role
      @where = "expenses-daily"
      @section = "reports1"

      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?

      kas = Bankexpensegroup.where("UPPER(name) = 'KAS' ").first

      @bankexpensecredit = Bankexpense.where("to_char(date, 'DD-MM-YYYY') = ? AND creditgroup_id = ? AND deleted = false", @date, kas.id)
      @bankexpensedebit = Bankexpense.where("to_char(date, 'DD-MM-YYYY') = ? AND debitgroup_id = ? AND deleted = false", @date, kas.id)
      @receipts = Receipt.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
      @receiptreturns = Receiptreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
      @officeexpensegroups = Officeexpensegroup.active
      @insurances = Invoice.where("money(insurance) > money(0) and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @gas_vouchers = Invoice.where("gas_voucher > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @gas_leftovers_out = Invoice.where("gas_leftover > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @gas_leftovers_in = Invoicereturn.where("gas_leftover > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @receiptpremis = Receiptpremi.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptorders = Receiptorder.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @productorders = Productorder.where("to_char(date, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @productorderitems = Productorderitem.where("to_char(created_at, 'DD-MM-YYYY') = ? AND bon = true", @date)
      @receiptexpenses = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptsales = Receiptsale.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @productrequests = Productrequest.where("deleted = false and date = ?", @date.to_date)

      @receiptdrivers = Receiptdriver.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptpayrolls = Receiptpayroll.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptpayrollreturns = Receiptpayrollreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)

      officepexpenses_debit = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Debit' AND deleted = false", @date)
      officepexpenses_credit = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Kredit' AND deleted = false", @date)
      @receipttrains = Receipttrain.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)
      @receiptships = Receiptship.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)

      if @date.to_date.year == 2013
        firstdate = Date.new(2013,7,1)
      else
        firstdate = @date.to_date.at_beginning_of_year
      end

      @bankexpensecreditold = Bankexpense.where("(date >= ? and date < ?) AND creditgroup_id = ? AND deleted = false", firstdate, @date.to_date, kas.id)
      @bankexpensedebitold = Bankexpense.where("(date >= ? and date < ?) AND debitgroup_id = ? AND deleted = false", firstdate, @date.to_date, kas.id)
      @receiptsold = Receipt.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date).order(:office_id)
      @receiptreturnsold = Receiptreturn.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date).order(:office_id)

      officepexpenses_debitold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Debit' AND deleted = false", firstdate, @date.to_date)
      officepexpenses_creditold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Kredit' AND deleted = false", firstdate, @date.to_date)
      officepexpenses_debitold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Debit' AND deleted = false", firstdate, @date.to_date)
      officepexpenses_creditold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Kredit' AND deleted = false", firstdate, @date.to_date)

      @receiptsalesold = Receiptsale.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptpremisold = Receiptpremi.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptordersold = Receiptorder.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)

      @receiptdriversold = Receiptdriver.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptpayrollsold = Receiptpayroll.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptpayrollreturnsold = Receiptpayrollreturn.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)

      @balance =  0
      @balance = @balance + @receiptreturnsold.sum(:total) + officepexpenses_debitold.sum(:total) + @receiptsalesold.sum(:total) + @bankexpensedebitold.sum(:total) + @receiptpayrollreturnsold.sum(:total)
      @balance = @balance - @receiptsold.sum(:total) - officepexpenses_creditold.sum(:total) - @receiptpremisold.sum(:total) - @receiptordersold.sum(:total) - @bankexpensecreditold.sum(:total) - @receiptdriversold.sum(:total) - @receiptpayrollsold.sum(:total) - @receipttrainsold.sum(:total) - @receiptshipsold.sum(:total)

      render "expenses-daily"
    else
      redirect_to root_path()
    end

  end

  def expenses_daily_new
    role = cek_roles 'Admin Keuangan, Admin Operasional'
    if role
    @where = "expenses-daily-new"
      @section = "reports1"

      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?

      kas = Bankexpensegroup.where("UPPER(name) = 'KAS' ").first

      # Hidden Kas
      @hiddenexpensedebit = Officeexpense.where("date = ? AND expensetype = 'Debit' AND deleted = false", @date.to_date).where(:officeexpensegroup_id => 60).order(:id)
      @hiddenexpensecredit = Officeexpense.where("date = ? AND expensetype = 'Kredit' AND deleted = false", @date.to_date).where(:officeexpensegroup_id => 60).order(:id)
      #######

      @bankexpensecredit = Bankexpense.where("to_char(date, 'DD-MM-YYYY') = ? AND creditgroup_id = ? AND deleted = false AND pettycashledger = false", @date, kas.id)
      @bankexpensedebit = Bankexpense.where("to_char(date, 'DD-MM-YYYY') = ? AND debitgroup_id = ? AND deleted = false AND pettycashledger = false", @date, kas.id)
      # render json: @bankexpensecredit
      # return false
      @receipts = Receipt.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
      @receiptreturns = Receiptreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
      @officeexpensegroups = Officeexpensegroup.active
      @insurances = Invoice.where("money(insurance) > money(0) and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @gas_vouchers = Invoice.where("gas_voucher > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @gas_leftovers_out = Invoice.where("gas_leftover > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @gas_leftovers_in = Invoicereturn.where("gas_leftover > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
      @receiptorders = Receiptorder.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @productorders = Productorder.where("to_char(date, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @productorderitems = Productorderitem.where("to_char(created_at, 'DD-MM-YYYY') = ? AND bon = true", @date)
      @receiptexpenses = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptsales = Receiptsale.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @productrequests = Productrequest.where("deleted = false and date = ?", @date.to_date)
      @receiptpremis = Receiptpremi.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptincentives = Receiptincentive.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)

      @receiptdrivers = Receiptdriver.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptpayrolls = Receiptpayroll.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptpayrollreturns = Receiptpayrollreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)

      officepexpenses_debit = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Debit' AND deleted = false", @date)
      officepexpenses_credit = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Kredit' AND deleted = false", @date)

      @premis = Invoice.joins(:receipts).where("invoices.premi_allowance > money(0) and to_char(receipts.created_at, 'DD-MM-YYYY') = ? AND invoices.deleted = false and receipts.deleted = false", @date).order(:office_id)
      @receipttrains = Receipttrain.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)
      @receiptships = Receiptship.active.where("to_char(created_at, 'DD-MM-YYYY') = ?", @date).order(:office_id)
      # @premis = Receipt.where("premi_allowance > money(0) and to_char(created_at, 'DD-MM-YYYY') = ? AND receipts.deleted = false", @date).order(:office_id)

      # render json: @premis
      # return false
      if @date.to_date.year == 2013
        firstdate = Date.new(2013,7,1)
      else
        firstdate = @date.to_date.at_beginning_of_year
      end

      @bankexpensecreditold = Bankexpense.where("(date >= ? and date < ?) AND creditgroup_id = ? AND deleted = false AND pettycashledger = false", firstdate, @date.to_date, kas.id)
      @bankexpensedebitold = Bankexpense.where("(date >= ? and date < ?) AND debitgroup_id = ? AND deleted = false AND pettycashledger = false", firstdate, @date.to_date, kas.id)
      @receiptsold = Receipt.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date).order(:office_id)
      @receiptreturnsold = Receiptreturn.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date).order(:office_id)
      @receipttrainsold = Receipttrain.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date).order(:office_id)
      @receiptshipsold = Receiptship.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date).order(:office_id)

      @hiddenexpensedebitold = Officeexpense.where("(date >= ? and date < ?) and expensetype = 'Debit' AND deleted = false", firstdate, @date.to_date).where(:officeexpensegroup_id => 60)
      @hiddenexpensecreditold = Officeexpense.where("(date >= ? and date < ?) and expensetype = 'Kredit' AND deleted = false", firstdate, @date.to_date).where(:officeexpensegroup_id => 60)

      officepexpenses_debitold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Debit' AND deleted = false", firstdate, @date.to_date)
      officepexpenses_creditold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Kredit' AND deleted = false", firstdate, @date.to_date)
      officepexpenses_debitold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Debit' AND deleted = false", firstdate, @date.to_date)
      officepexpenses_creditold = Receiptexpense.where("(created_at >= ? and created_at < ?) and expensetype = 'Kredit' AND deleted = false", firstdate, @date.to_date)

      @receiptsalesold = Receiptsale.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptordersold = Receiptorder.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptpremisold = Receiptpremi.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptincentivesold = Receiptincentive.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)

      @receiptdriversold = Receiptdriver.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptpayrollsold = Receiptpayroll.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)
      @receiptpayrollreturnsold = Receiptpayrollreturn.where("(created_at >= ? and created_at < ?) AND deleted = false", firstdate, @date.to_date)



      @balance =  0
      @balance = @balance + @hiddenexpensedebitold.sum(:total) + @receiptreturnsold.sum(:total) + officepexpenses_debitold.sum(:total) + @receiptsalesold.sum(:total) + @bankexpensedebitold.sum(:total) + @receiptpayrollreturnsold.sum(:total)
      @balance = @balance - @hiddenexpensecreditold.sum(:total) - @receiptsold.sum(:total) - officepexpenses_creditold.sum(:total) - @receiptpremisold.sum(:total) - @receiptincentivesold.sum(:total) - @receiptordersold.sum(:total) - @bankexpensecreditold.sum(:total) - @receiptdriversold.sum(:total) - @receiptpayrollsold.sum(:total) - @receipttrainsold.sum(:total) - @receiptshipsold.sum(:total)


      @support = Setting.find_by_name("Penyesuaian Saldo Setelah 1 November 2022").value.to_i
      @balance = @balance + @support


      offsetRunning = Setting.find_by_name("Offset Saldo Akhir 1 Nov").value.to_i

      @sdate = Date.new(2022, 11, 1)

      if @date.to_i > @sdate.strftime('%d-%m-%Y').to_i
        @balance = @balance - offsetRunning
      end

      render "expenses-daily-new"
    else
      redirect_to root_path()
    end

  end

  def expenses_bank
    role = cek_roles 'Admin Keuangan'
    if role
        @where = "expenses-bank"
      @section = "reports1"
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @bankexpensegroups = Bankexpensegroup.active.order(:name)
      @officeexpensegroups = Officeexpensegroup.active.order(:name)

      render "expenses-bank"
    else
      redirect_to root_path()
    end

  end

    def expenses_office
    role = cek_roles 'Admin Keuangan'
    if role
        @where = "expenses-office"
      @section = "reports1"
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @bankexpensegroups = Bankexpensegroup.active.order(:name)
      @officeexpensegroups = Officeexpensegroup.active.order(:name)

      render "expenses-office"
    else
      redirect_to root_path()
    end

  end

  def filterledger
    role = cek_roles 'Admin Keuangan'
    if role
        @where = "ledger"
      @section = "reports1"
      id_group_sangu = 999
      id_group_premi = 999
      id_groupbank_sangu = 25
      id_groupbank_premi = 32
      id_groupbank_solar = 27
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]


      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @bankexpensegroups = Bankexpensegroup.active.where("id not in (?,?,?)", id_groupbank_solar, id_groupbank_sangu, id_groupbank_premi).order(:name)
      @officeexpensegroups = Officeexpensegroup.active.where("officeexpensegroup_id is not null and id not in (?)", id_group_premi).order(:name)

      @groups = Array.new
      @groups.push("Sangu")
      @groups.push("Solar")
      # @groups.push("Premi")
      @groups.push("Onderdil Kontan")
      @groups.push("Penjualan Barang")
      @officeexpensegroups.each do |group|
        @groups.push(group.name)
      end

      @groupbanks = Array.new
      @bankexpensegroups.each do |group|
        @groupbanks.push(group.name)
      end
      # render json: {}
      render "filterledger"
    else
      redirect_to root_path()
    end

  end

  def ledger
    @where = "ledger"
    @section = "reports1"
    @inputs = params[:filterform]
    id_group_sangu = 0
    id_group_premi = 8
    id_groupbank_sangu = 25
    id_groupbank_premi = 32
    id_groupbank_solar = 27
    # @bankexpensegroups = Bankexpensegroup.active.where("id not in (?,?,?)", id_groupbank_solar, id_groupbank_sangu, id_groupbank_premi).order(:name)
    # @officeexpensegroups = Officeexpensegroup.active.where("officeexpensegroup_id is not null and id not in (?,?)", id_group_sangu, id_group_premi).order(:name)
    @bankexpensegroups = Bankexpensegroup.active.where("id not in (?,?,?)", id_groupbank_solar, id_groupbank_sangu, id_groupbank_premi).order(:name)
    @officeexpensegroups = Officeexpensegroup.active.where("officeexpensegroup_id is not null").order(:name)

    render "ledger"
    # render json: @officeexpensegroups.pluck(:name)
  end

  def balances
    role = cek_roles 'Admin Keuangan'
    if role
        @month = params[:month]
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      id_group_sangu = 54
      id_group_premi = 8
      id_groupbank_sangu = 25
      id_groupbank_premi = 32
      id_groupbank_solar = 27
      @bankexpensegroups = Bankexpensegroup.active.where("id not in (?,?,?)", id_groupbank_solar, id_groupbank_sangu, id_groupbank_premi).order(:name)
      @officeexpensegroups = Officeexpensegroup.active.where("officeexpensegroup_id is not null and id not in (?,?)", id_group_sangu, id_group_premi).order(:name)

      @section = "reports1"
      @where = "balances"
      render "balances"
    else
      redirect_to root_path()
    end

  end

  def expenses_gas
    role = cek_roles 'Admin Operasional, Admin HRD'
    if role

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      # @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @enddate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @enddate.nil?

      @office = params[:office_id]

      if @office.present?

        @office = Office.find(params[:office_id])
        @receipts = Receipt.where("created_at BETWEEN ? AND ? AND office_id = ? AND deleted = false", @startdate, @enddate, @office.id)

      else
        @office = Office.all.first
        @receipts = Receipt.where("created_at BETWEEN ? AND ? AND deleted = false", @startdate, @enddate)

      end

      @section = "reports2"
      @where = "expenses-gas"
      render "expenses-gas"
    else
      redirect_to root_path()
    end

  end

  def expenses_drivers
    role = cek_roles 'Admin Operasional, Admin HRD'
    if role
      @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
      @office = Office.find(params[:office_id]) if params[:office_id]
      @office = Office.all.first if @office.nil?
      @receipts = Receipt.where("to_char(created_at, 'DD-MM-YYYY') = ? and office_id = ? AND deleted = false", @date, @office.id)
      @receiptreturns = Receiptreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? and office_id = ? AND deleted = false", @date, @office.id)

      @section = "reports2"
      @where = "expenses-drivers"
      render "expenses-drivers"
    else
      redirect_to root_path()
    end

  end

  def gas_vouchers
    role = cek_roles 'Admin Operasional, Admin HRD'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      
      @invoices = Invoice.where("gas_voucher > 0 and (date > ? and date < ?) AND deleted = false", @startdate.to_date, @enddate.to_date).order('date')
      @invoices = @invoices.where("id not in (select invoice_id from invoicereturns where deleted = false)")

      @section = "reports2"
      @where = "gas-vouchers"
      render "gas-vouchers"
    else
      redirect_to root_path()
    end

  end

  def gas_leftovers
    role = cek_roles 'Admin Operasional, Admin HRD'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @vehicles = Invoice.find_by_sql(["
        select DISTINCT v.id, v.current_id
        from invoices i
        inner join vehicles v on i.vehicle_id = v.id
        where i.gas_leftover > 0 and (i.date > ? and i.date < ?)
        AND i.deleted = false
        group by v.id", @startdate.to_date, @enddate.to_date])
      @section = "reports2"
      @where = "gas-leftovers"
      render "gas-leftovers"
    else
      redirect_to root_path()
    end

  end

  def downloadexcelexpensedaily

    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?

    filename = "dailyreports_" + @date.to_date.strftime('%d%m%Y') + ".xls"

    kas = Bankexpensegroup.where("UPPER(name) = 'KAS' ").first

    @bankexpensecredit = Bankexpense.where("to_char(date, 'DD-MM-YYYY') = ? AND creditgroup_id = ? AND deleted = false", @date, kas.id)
    @bankexpensedebit = Bankexpense.where("to_char(date, 'DD-MM-YYYY') = ? AND debitgroup_id = ? AND deleted = false", @date, kas.id)
    @receipts = Receipt.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    @receiptreturns = Receiptreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date).order(:office_id)
    @officeexpensegroups = Officeexpensegroup.active
    @insurances = Invoice.where("money(insurance) > money(0) and date = ? AND deleted = false", @date.to_date).order(:office_id)
    @gas_vouchers = Invoice.where("gas_voucher > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
    @gas_leftovers_out = Invoice.where("gas_leftover > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
    @gas_leftovers_in = Invoicereturn.where("gas_leftover > 0 and date = ? AND deleted = false", @date.to_date).order(:office_id)
    @receiptorders = Receiptorder.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
    @productorders = Productorder.where("to_char(date, 'DD-MM-YYYY') = ? AND deleted = false", @date)
    @productorderitems = Productorderitem.where("to_char(created_at, 'DD-MM-YYYY') = ? AND bon = true", @date)
    @receiptexpenses = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
    @receiptsales = Receiptsale.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)

    @receiptpremis = Receiptpremi.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
    @receiptincentives = Receiptincentive.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)

    officepexpenses_debit = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Debit' AND deleted = false", @date)
    officepexpenses_credit = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Kredit' AND deleted = false", @date)

    # @balance = Setting.find_by_name("Saldo Kas Kantor").value.to_i rescue nil || 0
    cashdailylog = Cashdailylog.where("to_char(date, 'DD-MM-YYYY') = ?", @date).first.total rescue nil || 0
    @balance =  cashdailylog
    @balance = @balance - @receiptreturns.sum(:total) - officepexpenses_debit.sum(:total) - @bankexpensedebit.sum(:total) - @receiptsales.sum(:total)
    @balance = @balance + @receipts.sum(:total) + officepexpenses_credit.sum(:total) + @receiptpremis.sum(:total) + @receiptincentives.sum(:total) + @receiptorders.sum(:total) + @bankexpensecredit.sum(:total)

    green = Axlsx::Color.new :rgb => "FF00FF00"
    red = Axlsx::Color.new :rgb => "FFCC0033"

    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Kas Harian") do |sheet|

      bold = sheet.styles.add_style(:b => true)
      right = sheet.styles.add_style(:alignment => {:horizontal => :right})
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      h1 = sheet.styles.add_style :b => true, :sz => 16
      h2 = sheet.styles.add_style :b => true, :sz => 14
      h3_green = sheet.styles.add_style :color => green, :b => true
      h3_red = sheet.styles.add_style :color => red, :b => true
      number = sheet.styles.add_style :format_code => "#,##0.00"
      number_green = sheet.styles.add_style :format_code => "#,##0.00", :color => green, :b => true
      number_red = sheet.styles.add_style :format_code => "#,##0.00", :color => red, :b => true
      wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

      sheet.add_row [''], :height => 20
      sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Kas Harian: " + @date.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

      sheet.add_row [''], :height => 20
      sheet.add_row ['',"Saldo Awal: #{to_currency(@balance, 'Rp. ')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]

      sheet.add_row [''], :height => 20
      sheet.add_row ['','NO', 'KETERANGAN', 'KTR', 'NO.POL', 'DEBIT', 'KREDIT', 'SALDO' ] , :height => 20, :style => [nil, bold, bold, bold, bold, right_bold, right_bold, right_bold]

      running = @balance

      if @bankexpensedebit.where("money(total) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','BANK'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]
        @bankexpensedebit.where("money(total) > money(0)").each_with_index do |bankexpense, i|
          credit = Bankexpensegroup.find(bankexpense.creditgroup_id)
          running += bankexpense.total
          sheet.add_row ['',i + 1, "#{zeropad(bankexpense.id)}: Debit dari #{credit.name} (#{bankexpense.description})", bankexpense.office.abbr, '', bankexpense.total, 0, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end

        sheet.add_row ['','', "TOTAL",'', '', @bankexpensedebit.sum(:total), '', ''] , :height => 20, :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      if @receiptreturns.where("money(driver_allowance) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','UANG MAKAN SUPIR'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]
        @receiptreturns.where("money(driver_allowance) > money(0)").each_with_index do |receiptreturn, i|
          running += receiptreturn.driver_allowance
          sheet.add_row ['',i + 1, "#{zeropad(receiptreturn.invoice.id)}: #{receiptreturn.invoice.date.strftime("%d/%m/%y")}, #{receiptreturn.quantity} Rit, #{receiptreturn.invoice.route.name} (#{receiptreturn.invoice.driver.name})", receiptreturn.office.abbr, receiptreturn.invoice.vehicle.current_id, receiptreturn.driver_allowance, 0, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', @receiptreturns.sum(:driver_allowance), '', ''] , :height => 20, :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      if @receiptreturns.where("money(helper_allowance) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','UANG MAKAN KERNET'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]
        @receiptreturns.where("money(helper_allowance) > money(0)").each_with_index do |receiptreturn, i|
          running += receiptreturn.helper_allowance
          sheet.add_row ['',i + 1, "#{zeropad(receiptreturn.invoice.id)}: #{receiptreturn.invoice.date.strftime("%d/%m/%y")}, #{receiptreturn.quantity} Rit, #{receiptreturn.invoice.route.name} (#{receiptreturn.invoice.driver.name})", receiptreturn.office.abbr, receiptreturn.invoice.vehicle.current_id, receiptreturn.helper_allowance, 0, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', @receiptreturns.sum(:helper_allowance), '', ''] , :height => 20, :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      if @receiptreturns.where("money(misc_allowance + tol_fee)> money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','LAIN-LAIN'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]
        @receiptreturns.where("money(misc_allowance + tol_fee)> money(0)").each_with_index do |receiptreturn, i|
          running += receiptreturn.misc_allowance + receiptreturn.tol_fee
          sheet.add_row ['',i + 1, "#{zeropad(receiptreturn.invoice.id)}: #{receiptreturn.invoice.date.strftime("%d/%m/%y")}, #{receiptreturn.quantity} Rit, #{receiptreturn.invoice.route.name} (#{receiptreturn.invoice.driver.name})", receiptreturn.office.abbr, receiptreturn.invoice.vehicle.current_id, receiptreturn.misc_allowance + receiptreturn.tol_fee, 0, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', @receiptreturns.sum("misc_allowance + tol_fee"), '', ''], :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      umum = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Debit' AND deleted = false AND (officeexpensegroup_id = 1 OR officeexpensegroup_id in (SELECT id from officeexpensegroups where officeexpensegroup_id = 1))", @date).order(:id)

      if umum.any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','KAS UMUM'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]

        umum.each_with_index do |expense, i|
          running += expense.total
          current_id = expense.officeexpense.vehicle.current_id unless expense.officeexpense.vehicle.nil?
          sheet.add_row ['',i + 1, expense.officeexpense.description.gsub('<br />', '\n'), expense.officeexpense.office.abbr, current_id, expense.total, 0, running], :style => [nil, nil, wrap_txt, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', umum.sum(:total), '', ''] , :height => 20, :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      kantor = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Debit' AND deleted = false AND (officeexpensegroup_id = 5 OR officeexpensegroup_id in (SELECT id from officeexpensegroups where officeexpensegroup_id = 5))", @date).order(:id)

      if kantor.any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','KAS KANTOR'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]

        kantor.each_with_index do |expense, i|
          running += expense.total
          current_id = expense.officeexpense.vehicle.current_id unless expense.officeexpense.vehicle.nil?
          sheet.add_row ['',i + 1, expense.officeexpense.description.gsub('<br />', '\n'), expense.officeexpense.office.abbr, current_id, expense.total, 0, running], :style => [nil, nil, wrap_txt, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', kantor.sum(:total), '', ''] , :height => 20, :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      if @receiptsales.where("money(total) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','PENJUALAN BARANG'] , :height => 20, :style => [nil, h3_green], :widths => [:auto, :ignore]
        @receiptsales.where("money(total) > money(0)").each_with_index do |receiptsale, i|
          running += receiptsale.total

          productname = ""
          receiptsale.sale.saleitems.each do |item|
            productname += item.productsale.name + ", "
          end
          productname = productname[0...-2]
          sheet.add_row ['',i + 1, getwords(productname, 35), '', '', receiptsale.total, 0, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', @receiptsales.where("money(total) > money(0)"), '', ''] , :height => 20, :style => [nil, nil, bold, nil, nil, number_green, nil, nil ]
      end

      if @bankexpensecredit.where("money(total) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','BANK'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @bankexpensecredit.where("money(total) > money(0)").each_with_index do |bankexpense, i|
          credit = Bankexpensegroup.find(bankexpense.creditgroup_id)
          running -= bankexpense.total
          sheet.add_row ['',i + 1, "#{zeropad(bankexpense.id)}: Debit dari #{credit.name} (#{bankexpense.description})", bankexpense.office.abbr, '', 0, bankexpense.total, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end

        sheet.add_row ['','', "TOTAL",'', '', '', @bankexpensecredit.sum(:total),  ''] , :height => 20, :style => [nil, nil, bold, nil, nil, nil, number_red, nil ]
      end

      if @receipts.where("money(driver_allowance) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','UANG MAKAN SUPIR'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receipts.where("money(driver_allowance) > money(0)").each_with_index do |receipt, i|
          running -= receipt.driver_allowance
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{receipt.invoice.date.strftime("%d/%m/%y")}, #{receipt.quantity} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.office.abbr, receipt.invoice.vehicle.current_id, 0, receipt.driver_allowance, running] , :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', @receipts.sum(:driver_allowance), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      if @receipts.where("money(helper_allowance) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','UANG MAKAN KERNET'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receipts.where("money(helper_allowance) > money(0)").each_with_index do |receipt, i|
          running -= receipt.helper_allowance
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{receipt.invoice.date.strftime("%d/%m/%y")}, #{receipt.quantity} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.office.abbr, receipt.invoice.vehicle.current_id, 0,  receipt.helper_allowance, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', @receipts.sum(:helper_allowance), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      if @receipts.where("money(misc_allowance + tol_fee + ferry_fee) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','LAIN-LAIN'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receipts.where("money(misc_allowance + tol_fee)> money(0)").each_with_index do |receipt, i|
          running -= receipt.misc_allowance + receipt.tol_fee + receipt.ferry_fee
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{receipt.invoice.date.strftime("%d/%m/%y")}, #{receipt.quantity} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.office.abbr, receipt.invoice.vehicle.current_id, 0, receipt.misc_allowance + receipt.tol_fee + receipt.ferry_fee, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', @receipts.sum("misc_allowance + tol_fee + ferry_fee"), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      if @receipts.where("money(gas_allowance) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','SOLAR KONTAN'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receipts.where("money(gas_allowance) > money(0)").each_with_index do |receipt, i|
          running -= receipt.gas_allowance
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{receipt.invoice.date.strftime("%d/%m/%y")}, #{receipt.quantity} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.office.abbr, receipt.invoice.vehicle.current_id, 0,  receipt.gas_allowance, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', @receipts.sum(:gas_allowance), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      if @receiptpremis.where("money(total) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','PREMI'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receiptpremis.where("money(total) > money(0)").each_with_index do |receipt, i|
          running -= receipt.total
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{receipt.invoice.date.strftime("%d/%m/%y")}, #{receipt.bonusreceipt.quantity} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.bonusreceipt.office.abbr, receipt.invoice.vehicle.current_id, 0,  receipt.total, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', @receiptpremis.sum(:total), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      if @receiptincentives.where("money(total) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','INSENTIF'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receiptincentives.where("money(total) > money(0)").each_with_index do |receipt, i|
          running -= receipt.total
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{receipt.invoice.date.strftime("%d/%m/%y")}, #{receipt.incentive.quantity} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.incentive.office.abbr, receipt.invoice.vehicle.current_id, 0,  receipt.total, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', @receiptincentives.sum(:total), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      if @receiptorders.where("money(total) > money(0)").any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','ONDERDIL KONTAN'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]
        @receiptorders.where("money(total) > money(0)").each_with_index do |receiptorder, i|
          running -= receiptorder.total

          productname = ""
          receiptorder.productorder.productorderitems.each do |item|
            productname += item.product.name + ", "
          end
          productname = productname[0...-2]

          sheet.add_row ['',i + 1, getwords(productname, 35) , '', '', 0,  receiptorder.total, running], :style => [nil, nil, nil, nil, nil, number, number, number ]
        end

        sheet.add_row ['','', "TOTAL",'', '', '', @receiptorders.sum(:total), ''] , :height => 20, :style => [nil, nil, bold, nil, nil,  nil, number_red, nil ]
      end

      umum = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Kredit' AND deleted = false AND (officeexpensegroup_id = 1 OR officeexpensegroup_id in (SELECT id from officeexpensegroups where officeexpensegroup_id = 1))", @date).order(:id)

      if umum.any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','KAS UMUM'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]

        umum.each_with_index do |expense, i|
          running -= expense.total
          current_id = expense.officeexpense.vehicle.current_id unless expense.officeexpense.vehicle.nil?
          sheet.add_row ['',i + 1, expense.officeexpense.description.gsub('<br />', '\n'), expense.officeexpense.office.abbr, current_id, 0, expense.total, running], :style => [nil, nil, wrap_txt, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', umum.sum(:total), ''] , :height => 20, :style => [nil, nil, bold, nil, nil, nil, number_red, nil ]
      end

      kantor = Receiptexpense.where("to_char(created_at, 'DD-MM-YYYY') = ? and expensetype = 'Kredit' AND deleted = false AND (officeexpensegroup_id = 5 OR officeexpensegroup_id in (SELECT id from officeexpensegroups where officeexpensegroup_id = 5))", @date).order(:id)

      if kantor.any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','KAS KANTOR'] , :height => 20, :style => [nil, h3_red], :widths => [:auto, :ignore]

        kantor.each_with_index do |expense, i|
          running -= expense.total
          current_id = expense.officeexpense.vehicle.current_id unless expense.officeexpense.vehicle.nil?
          sheet.add_row ['',i + 1, expense.officeexpense.description.gsub('<br />', '\n'), expense.officeexpense.office.abbr, current_id, 0, expense.total, running] , :style => [nil, nil, wrap_txt, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', kantor.sum(:total), ''] , :height => 20, :style => [nil, nil, bold, nil, nil, nil, number_red, nil ]
      end

      sheet.add_row [''], :height => 20
      sheet.add_row ['',"Saldo Akhir: #{to_currency(running, 'Rp. ')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]

      sheet.column_widths nil, 5, 100, 10, 10, 15, 15, 15
    end

    p.workbook.add_worksheet(:name => "Solar Bon & Gantungan Solar") do |sheet|
      h1 = sheet.styles.add_style :b => true, :sz => 16
      h2 = sheet.styles.add_style :b => true, :sz => 14
      number = sheet.styles.add_style :format_code => "#,##0.00"
      bold = sheet.styles.add_style :b => true
      right = sheet.styles.add_style :alignment => {:horizontal => :right}
      right_bold = sheet.styles.add_style :alignment => {:horizontal => :right}, :b => true
      number_green = sheet.styles.add_style :color => green, :format_code => "#,##0.00", :b => true
      number_red = sheet.styles.add_style :color => red, :format_code => "#,##0.00",  :b => true

      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

      sheet.add_row [''], :height => 20
      sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Solar Bon dan Gantungan Solar: " + @date.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

      if @gas_vouchers.any?
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','SOLAR BON'] , :height => 20, :style => [nil, h2], :widths => [:auto, :ignore]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'KETERANGAN', 'KTR', 'NO.POL', 'LITER', 'SOLAR', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, bold, right_bold, right_bold, right_bold]

        total = 0
        @gas_vouchers.each_with_index do |invoice, i|
          total += invoice.gas_voucher.to_i * invoice.gas_cost.to_i
          sheet.add_row ['',i + 1, "#{zeropad(invoice.id)}: #{invoice.date.strftime("%d/%m/%y")}, #{invoice.quantity} Rit, #{invoice.route.name} (#{invoice.driver.name})", invoice.office.abbr, invoice.vehicle.current_id, invoice.gas_voucher, invoice.gas_cost, invoice.gas_voucher.to_i * invoice.gas_cost.to_i] , :style => [nil, nil, nil, nil, nil, number, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', @gas_vouchers.sum('gas_voucher'), '',total] , :height => 20, :style => [nil, nil, bold, nil, nil, number, nil, number ]
      end

      if @gas_leftovers_out.any? or @gas_leftovers_in.any?
        i = 0
        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','GANTUNGAN SOLAR'] , :height => 20, :style => [nil, h2], :widths => [:auto, :ignore]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'KETERANGAN', 'KTR', 'NO.POL', 'LITER', 'SOLAR', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, bold, right_bold, right_bold, right_bold]

        @gas_leftovers_out.each do |invoice|
          sheet.add_row ['',i + 1, "#{zeropad(invoice.id)}: #{invoice.quantity} Rit, #{invoice.route.name} (#{invoice.driver.name})", invoice.office.abbr, invoice.vehicle.current_id, invoice.gas_leftover, invoice.gas_cost.to_i, invoice.gas_leftover.to_i * invoice.gas_cost.to_i] , :style => [nil, nil, nil, nil, nil, number_red, number, number_red ]
        end

        @gas_leftovers_in.each do |invoicereturn|
          sheet.add_row ['',i + 1, "#{zeropad(invoicereturn.invoice.id)}: #{invoicereturn.quantity} Rit, #{invoicereturn.invoice.route.name} (#{invoicereturn.invoice.driver.name})", invoicereturn.office.abbr, invoicereturn.invoice.vehicle.current_id, invoicereturn.gas_leftover, invoicereturn.invoice.gas_cost.to_i, invoicereturn.gas_leftover.to_i * invoicereturn.invoice.gas_cost.to_i] , :style => [nil, nil, nil, nil, nil, number_green, number, number_green ]
        end
      end
    end

    if @insurances.any?
      p.workbook.add_worksheet(:name => "Asuransi") do |sheet|
        h1 = sheet.styles.add_style :b => true, :sz => 16
        h2 = sheet.styles.add_style :b => true, :sz => 14
        number = sheet.styles.add_style :format_code => "#,##0.00"
        bold = sheet.styles.add_style :b => true
        right = sheet.styles.add_style :alignment => {:horizontal => :right}
        right_bold = sheet.styles.add_style :alignment => {:horizontal => :right}, :b => true

        sheet.add_row [''], :height => 20
        sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

        sheet.add_row [''], :height => 20
        sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Asuransi: " + @date.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

        sheet.add_row [''], :height => 20, :widths => [:auto, :ignore]
        sheet.add_row ['','ASURANSI'] , :height => 20, :style => [nil, h2], :widths => [:auto, :ignore]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'KETERANGAN', 'KTR', 'NO.POL', 'UP', 'RATE', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, bold, right_bold, right_bold, right_bold]

        total_insurances = 0
        @insurances.each_with_index do |invoice, i|
          total_insurances += invoice.insurance * invoice.insurance_rate.to_f
          sheet.add_row ['',i + 1, "#{zeropad(invoice.id)}: #{invoice.quantity} Rit, #{invoice.route.name} (#{invoice.driver.name})", invoice.office.abbr, invoice.vehicle.current_id, invoice.insurance, invoice.insurance_rate, invoice.insurance * invoice.insurance_rate.to_f] , :style => [nil, nil, nil, nil, nil, number, nil, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', '',total_insurances] , :height => 20, :style => [nil, nil, bold, nil, nil, nil, nil, number ]
      end
    end

    if @receipts.any?
      p.workbook.add_worksheet(:name => "Estimasi Pendapatan BKK") do |sheet|
        h1 = sheet.styles.add_style :b => true, :sz => 16
        h2 = sheet.styles.add_style :b => true, :sz => 14
        number = sheet.styles.add_style :format_code => "#,##0.00"
        bold = sheet.styles.add_style :b => true
        right = sheet.styles.add_style :alignment => {:horizontal => :right}
        right_bold = sheet.styles.add_style :alignment => {:horizontal => :right}, :b => true
        number_right_bold = sheet.styles.add_style :alignment => {:horizontal => :right}, :b => true, :format_code => "#,##0.00"

        sheet.add_row [''], :height => 20
        sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

        sheet.add_row [''], :height => 20
        sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Estimasi Pendapatan BKK: " + @date.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'KETERANGAN', 'KTR', 'NO.POL', 'KG', 'HARGA', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, bold, right_bold, right_bold, right_bold]

        tipe = ''
        total_estimation = estimation =  i = qty = 0
        @receipts.each_with_index do |receipt, i|
          qty = receipt.invoice.quantity
          qty -= receipt.invoice.receiptreturns.where(:deleted => false).first.quantity if !receipt.invoice.receiptreturns.where(:deleted => false).first.nil?
          if receipt.invoice.price_per >= 300000
            estimation = qty * receipt.invoice.price_per.to_i
            tipe = 'BORONGAN'
          else
            estimation = qty * 25000 * receipt.invoice.price_per.to_i
            tipe = '25.000'
          end
          total_estimation += estimation
          sheet.add_row ['',i + 1, "#{zeropad(receipt.invoice.id)}: #{qty} Rit, #{receipt.invoice.route.name} (#{receipt.invoice.driver.name})", receipt.invoice.office.abbr, receipt.invoice.vehicle.current_id, tipe, receipt.invoice.price_per, estimation] , :style => [nil, nil, nil, nil, nil, right, number, number ]
        end
        sheet.add_row ['','', "TOTAL",'', '', '', '',total_estimation] , :height => 20, :style => [nil, nil, bold, nil, nil, nil, nil, number_right_bold ]
      end


      if @productorders and @productorders.any? and @productorderitems.count > 0
        p.workbook.add_worksheet(:name => "Pembelian Bon") do |sheet|
          h1 = sheet.styles.add_style :b => true, :sz => 16
          h2 = sheet.styles.add_style :b => true, :sz => 14
          number = sheet.styles.add_style :format_code => "#,##0.00"
          bold = sheet.styles.add_style :b => true
          right = sheet.styles.add_style :alignment => {:horizontal => :right}
          right_bold = sheet.styles.add_style :alignment => {:horizontal => :right}, :b => true
          number_right_bold = sheet.styles.add_style :alignment => {:horizontal => :right}, :b => true, :format_code => "#,##0.00"

          sheet.add_row [''], :height => 20
          sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

          sheet.add_row [''], :height => 20
          sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Pembelian Bon: " + @date.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

          sheet.add_row [''], :height => 20
          sheet.add_row ['','NO', 'KETERANGAN', 'SUPPLIER', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, right_bold]

          total_bon = 0
          i = 1
          @productorders.each do |productorder|
            productorder.productorderitems.where(:bon => true).each do |productorderitem|
              sheet.add_row ['',i, "#{zeropad(productorder.id)}: #{productorderitem.quantity}x #{productorderitem.product.name}", productorderitem.supplier.name, productorderitem.total] , :style => [nil, nil, nil, nil, number ]
              total_bon += productorderitem.total.to_i
              i += 1
            end
          end
          sheet.add_row ['','', "TOTAL",'',total_bon] , :height => 20, :style => [nil, nil, bold, nil, number_right_bold ]
        end
      end

    end

    p.use_autowidth = false
    p.use_shared_strings = true

    send_data(p.to_stream.read, :filename => filename, :type => :xls, :x_sendfile => true)
  end

  def getannualreportvehicle
    @vehicle_id = params[:vehicle_id]
    income = Array.new
    outcome = Array.new

    @year = Date.today.year
    (1..12).each do |i|
      taxinvoices = Taxinvoiceitem.where("extract(month from date) = #{i} and extract(year from date) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{@vehicle_id})").sum(:total)
      inc_others = Receiptexpense.where("extract(month from created_at) = #{i} and extract(year from created_at) = #{@year} and expensetype = 'Debit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{@vehicle_id})").sum(:total)

      income.push((taxinvoices.to_i + inc_others.to_i)/1000)

      receipts = Receipt.where("extract(month from created_at) = #{i} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{@vehicle_id})").sum(:total)
      receiptreturns = Receiptreturn.where("invoice_id in (SELECT r.invoice_id from receipts r inner join invoices i on r.invoice_id = i.id where extract(month from r.created_at) = #{i} and extract(year from r.created_at) = #{@year} and r.deleted = false and i.vehicle_id = #{@vehicle_id})").sum(:total)
      receiptpremis = Receiptpremi.where("extract(month from created_at) = #{i} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{@vehicle_id})").sum(:total)
      receiptincentives = Receiptincentive.where("extract(month from created_at) = #{i} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{@vehicle_id})").sum(:total)
      receiptexpenses = Receiptexpense.where("extract(month from created_at) = #{i} and extract(year from created_at) = #{@year} and expensetype = 'Kredit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{@vehicle_id})").sum(:total)
      productrequests = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(month from date) = #{i} and extract(year from date) = #{@year} and deleted = false and vehicle_id = #{@vehicle_id})").sum(:total)

      outcome.push((receipts.to_i + receiptpremis.to_i + receiptincentives.to_i + receiptexpenses.to_i + productrequests.to_i - receiptreturns.to_i)/1000)
    end

    objreturn = Array.new
    objreturn.push(income)
    objreturn.push(outcome)

    respond_to do |format|
      format.json {render :json => objreturn }
    end
  end

  def sales
    role = cek_roles 'Admin HRD, Admin Gudang'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @receiptsales = Receiptsale.where("(created_at > ? and created_at < ?) AND deleted = false", @startdate.to_date, @enddate.to_date).order('date')

      @section = "reports2"
      @where = "reports-sales"
      render "sales"
    else
      redirect_to root_path()
    end

  end

  def expensesdriverdaily
    role = cek_roles 'Admin HRD'
    if role
        @date = params[:date]
      @date = Date.today.strftime('%d-%m-%Y') if @date.nil?

      @receiptdrivers = Receiptdriver.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptpayrolls = Receiptpayroll.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)
      @receiptpayrollreturns = Receiptpayrollreturn.where("to_char(created_at, 'DD-MM-YYYY') = ? AND deleted = false", @date)

      @section = "reports1"
      @where = "expensesdriverdaily"
      render "expensesdriverdaily"
    else
      redirect_to root_path()
    end

  end

  def payroll
    role = cek_roles 'Admin HRD'
    if role
        @month = params[:month] || Date.today.month.to_s
      @year = params[:year] || Date.today.year
      @date = Date.new(@year.to_i, @month.to_i, 1) + 1.month

      @maindrivers = Payroll.where("to_char(date, 'MM-YYYY') = ? AND deleted = false and id not in (SELECT payroll_id FROM receiptpayrollreturns WHERE deleted = false) and driver_id in (select id from drivers where deleted = false and status = 'Tetap')",@date.strftime('%m-%Y'))
      @warnens = Payroll.where("to_char(date, 'MM-YYYY') = ? AND deleted = false and id not in (SELECT payroll_id FROM receiptpayrollreturns WHERE deleted = false) and driver_id in (select id from drivers where deleted = false and status = 'Warnen')",@date.strftime('%m-%Y'))
      @helpers = Payroll.where("to_char(date, 'MM-YYYY') = ? AND deleted = false and id not in (SELECT payroll_id FROM receiptpayrollreturns WHERE deleted = false) and helper_id in (select id from helpers where deleted = false)",@date.strftime('%m-%Y'))
      @section = "reports1"
      @where = "reports-payroll"
      render "payroll"
    else
      redirect_to root_path()
    end

  end

  def invoicereturns
    role = cek_roles 'Admin Keuangan, Admin Operasional'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @receiptreturns = Receiptreturn.where("(created_at >= ? and created_at < ?) AND deleted = false", @startdate.to_date, @enddate.to_date + 1.day).order('created_at')
      @invoicereturns = Invoicereturn.where("(date >= ? and date <= ?) AND id not in (select invoicereturn_id from receiptreturns where deleted = false and invoicereturn_id is not null) AND deleted = false", @startdate.to_date, @enddate.to_date)

      @where = "reports-invoicereturns"
      @section = "reports1"
      render "invoicereturns"
    else
      redirect_to root_path()
    end

  end


  def downloadexcelpayroll
    @date = params[:date].to_date
    @date_period = (@date - 1.month).to_date

    @maindrivers = Payroll.where("to_char(date, 'MM-YYYY') = ? AND deleted = false and id not in (SELECT payroll_id FROM receiptpayrollreturns WHERE deleted = false) and driver_id in (select id from drivers where deleted = false and status = 'Tetap')",@date.strftime('%m-%Y'))
    @warnens = Payroll.where("to_char(date, 'MM-YYYY') = ? AND deleted = false and id not in (SELECT payroll_id FROM receiptpayrollreturns WHERE deleted = false) and driver_id in (select id from drivers where deleted = false and status = 'Warnen')",@date.strftime('%m-%Y'))
    @helpers = Payroll.where("to_char(date, 'MM-YYYY') = ? AND deleted = false and id not in (SELECT payroll_id FROM receiptpayrollreturns WHERE deleted = false) and helper_id in (select id from helpers where deleted = false)",@date.strftime('%m-%Y'))
    filename = "payrollreports_" + @date.to_date.strftime('%d%m%Y') + ".xls"

    p = Axlsx::Package.new
    if @maindrivers.any?
      p.workbook.add_worksheet(:name => "Supir") do |sheet|
        bold = sheet.styles.add_style(:b => true)
        bold_top_left_right = sheet.styles.add_style(:b => true, :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :center, :vertical => :center} )

        top_left_right = sheet.styles.add_style(:border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :left} )
        center_top_left_right = sheet.styles.add_style(:border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :center} )
        number_top_left_right = sheet.styles.add_style(:format_code => "#,##0.00", :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :right} )
        bold_number_top_left_right_bottom = sheet.styles.add_style(:b => true, :format_code => "#,##0.00", :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right, :bottom] }, :alignment => { :horizontal => :right} )
        bold_center_top_left_right_bottom = sheet.styles.add_style(:b => true, :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right,:bottom] }, :alignment => { :horizontal => :center} )


        right = sheet.styles.add_style(:alignment => {:horizontal => :right})
        right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
        h1 = sheet.styles.add_style :b => true, :sz => 16
        h2 = sheet.styles.add_style :b => true, :sz => 14
        number = sheet.styles.add_style :format_code => "#,##0.00"
        wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

        sheet.add_row [''], :height => 20
        sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " - Divisi Marketing"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

        sheet.add_row [''], :height => 20
        sheet.add_row ['', "Gaji Sopir Tetap"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]
        sheet.add_row ['',"Bulan   : #{@date_period.strftime('%^B %Y')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]
        sheet.add_row ['',"Periode : #{@date_period.strftime('%d %B %Y')} s/d #{(@date_period.next_month - 1.day).strftime('%d %B %Y')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'NO.POL', 'NAMA', 'KEHADIRAN', '', '', 'KLAIM SUSUT', '', '', 'KLAIM KECELAKAAN', '', '', 'KLAIM ONDERDIL', 'POT', 'SISA', 'PINJAMAN', '', '', 'GANTUNGAN SANGU', 'TABUNGAN', '', '','', 'TOTAL POTONGAN', 'PENGHARGAAN KEHADIRAN', '', '', '', 'BIAYA JASA BERSIH' ] , :height => 20, :style => [nil, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right]
        sheet.add_row ['','', '', '', 'NON HLN', 'HLN', 'TOTAL HADIR', 'KLAIM', 'POT', 'SISA', 'KLAIM', 'POT', 'SISA', 'KLAIM', 'POT', 'SISA', 'JUMLAH', 'POT', 'SISA', 'GANTUNGAN SANGU', 'TABUNGAN AWAL', 'AMBIL TABUNGAN', 'TABUNGAN','TOTAL TABUNGAN', 'TOTAL POTONGAN', 'NON HLN', 'HLN', 'PREMI HADIR', 'TOTAL', 'BIAYA JASA BERSIH' ] , :height => 20, :style => [nil, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right]

        sheet.merge_cells "B8:B9"
        sheet.merge_cells "C8:C9"
        sheet.merge_cells "D8:D9"
        sheet.merge_cells "E8:G8"
        sheet.merge_cells "H8:J8"
        sheet.merge_cells "K8:M8"
        sheet.merge_cells "N8:P8"
        sheet.merge_cells "Q8:S8"
        sheet.merge_cells "U8:X8"
        sheet.merge_cells "Z8:AC8"

        @maindrivers.order(:id).each_with_index do |driver, i|
          sheet.add_row ['',i+1, (driver.vehicle.current_id rescue ''), (driver.driver.name rescue ''), driver.non_holidays, driver.holidays, driver.holidays + driver.non_holidays, driver.master_weight_loss, driver.weight_loss, driver.master_weight_loss-driver.weight_loss, driver.master_accident, driver.accident, driver.master_accident.to_f - driver.accident.to_f, driver.master_sparepart, driver.sparepart, driver.master_sparepart.to_f - driver.sparepart.to_f, driver.master_bon, driver.bon, driver.master_bon.to_f - driver.bon.to_f, driver.allowance, driver.master_saving, driver.saving_reduction, driver.saving, driver.master_saving.to_f - driver.saving_reduction.to_f + driver.saving.to_f, driver.weight_loss.to_f + driver.sparepart.to_f + driver.accident.to_f + driver.bon.to_f + driver.saving.to_f + driver.allowance.to_f, driver.non_holidays_payment, driver.holidays_payment, driver.bonus, driver.non_holidays_payment.to_f + driver.holidays_payment.to_f + driver.bonus.to_f, driver.total ] , :height => 20, :style => [nil, center_top_left_right, top_left_right, top_left_right, center_top_left_right, center_top_left_right, center_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right]
        end

        sheet.add_row ['','','', 'TOTAL', @maindrivers.sum(:non_holidays), @maindrivers.sum(:holidays), @maindrivers.sum('holidays + non_holidays'), @maindrivers.sum(:master_weight_loss), @maindrivers.sum(:weight_loss), @maindrivers.sum("master_weight_loss-weight_loss"), @maindrivers.sum(:master_accident), @maindrivers.sum(:accident),@maindrivers.sum("master_accident-accident"), @maindrivers.sum(:master_sparepart), @maindrivers.sum(:sparepart), @maindrivers.sum("master_sparepart-sparepart"), @maindrivers.sum(:master_bon), @maindrivers.sum(:bon), @maindrivers.sum("master_bon-bon"), @maindrivers.sum(:allowance), @maindrivers.sum(:master_saving), @maindrivers.sum(:saving_reduction), @maindrivers.sum(:saving), @maindrivers.sum("master_saving-saving_reduction+saving"), @maindrivers.sum("weight_loss+sparepart+accident+bon+saving+allowance"), @maindrivers.sum(:non_holidays_payment), @maindrivers.sum(:holidays_payment), @maindrivers.sum(:bonus), @maindrivers.sum("non_holidays_payment+holidays_payment+bonus"), @maindrivers.sum(:total) ] , :height => 20, :style => [nil, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_center_top_left_right_bottom, bold_center_top_left_right_bottom, bold_center_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom]
      end
    end

    if @warnens.any?
      p.workbook.add_worksheet(:name => "Warnen") do |sheet|
        bold = sheet.styles.add_style(:b => true)
        bold_top_left_right = sheet.styles.add_style(:b => true, :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :center, :vertical => :center} )

        top_left_right = sheet.styles.add_style(:border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :left} )
        center_top_left_right = sheet.styles.add_style(:border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :center} )
        number_top_left_right = sheet.styles.add_style(:format_code => "#,##0.00", :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :right} )
        bold_number_top_left_right_bottom = sheet.styles.add_style(:b => true, :format_code => "#,##0.00", :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right, :bottom] }, :alignment => { :horizontal => :right} )
        bold_center_top_left_right_bottom = sheet.styles.add_style(:b => true, :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right,:bottom] }, :alignment => { :horizontal => :center} )


        right = sheet.styles.add_style(:alignment => {:horizontal => :right})
        right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
        h1 = sheet.styles.add_style :b => true, :sz => 16
        h2 = sheet.styles.add_style :b => true, :sz => 14
        number = sheet.styles.add_style :format_code => "#,##0.00"
        wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

        sheet.add_row [''], :height => 20
        sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " - Divisi Marketing"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

        sheet.add_row [''], :height => 20
        sheet.add_row ['', "Gaji Sopir Tetap (Baru)"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]
        sheet.add_row ['',"Bulan   : #{@date_period.strftime('%^B %Y')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]
        sheet.add_row ['',"Periode : #{@date_period.strftime('%d %B %Y')} s/d #{(@date_period.next_month - 1.day).strftime('%d %B %Y')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'NO.POL', 'NAMA', 'KEHADIRAN', '', '', 'KLAIM SUSUT', '', '', 'KLAIM KECELAKAAN', '', '', 'KLAIM ONDERDIL', 'POT', 'SISA', 'PINJAMAN', '', '', 'GANTUNGAN SANGU', 'TABUNGAN', '', '','', 'TOTAL POTONGAN', 'PENGHARGAAN KEHADIRAN', '', '', '', 'BIAYA JASA BERSIH' ] , :height => 20, :style => [nil, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right]
        sheet.add_row ['','', '', '', 'NON HLN', 'HLN', 'TOTAL HADIR', 'KLAIM', 'POT', 'SISA', 'KLAIM', 'POT', 'SISA', 'KLAIM', 'POT', 'SISA', 'JUMLAH', 'POT', 'SISA', 'GANTUNGAN SANGU', 'TABUNGAN AWAL', 'AMBIL TABUNGAN', 'TABUNGAN','TOTAL TABUNGAN', 'TOTAL POTONGAN', 'NON HLN', 'HLN', 'PREMI HADIR', 'TOTAL', 'BIAYA JASA BERSIH' ] , :height => 20, :style => [nil, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right]

        sheet.merge_cells "B8:B9"
        sheet.merge_cells "C8:C9"
        sheet.merge_cells "D8:D9"
        sheet.merge_cells "E8:G8"
        sheet.merge_cells "H8:J8"
        sheet.merge_cells "K8:M8"
        sheet.merge_cells "N8:P8"
        sheet.merge_cells "Q8:S8"
        sheet.merge_cells "U8:X8"
        sheet.merge_cells "Z8:AC8"

        @warnens.order(:id).each_with_index do |driver, i|
          sheet.add_row ['',i+1, (driver.vehicle.current_id rescue ''), (driver.driver.name rescue '-'), driver.non_holidays, driver.holidays, driver.holidays + driver.non_holidays, driver.master_weight_loss, driver.weight_loss, driver.master_weight_loss.to_f - driver.weight_loss.to_f, driver.master_accident, driver.accident, driver.master_accident.to_f - driver.accident.to_f, driver.master_sparepart, driver.sparepart, driver.master_sparepart.to_f - driver.sparepart.to_f, driver.master_bon, driver.bon, driver.master_bon.to_f - driver.bon.to_f, driver.allowance, driver.master_saving, driver.saving_reduction, driver.saving, driver.master_saving.to_f - driver.saving_reduction.to_f + driver.saving.to_f, driver.weight_loss.to_f + driver.sparepart.to_f + driver.accident.to_f + driver.bon.to_f + driver.saving.to_f + driver.allowance.to_f, driver.non_holidays_payment, driver.holidays_payment, driver.bonus, driver.non_holidays_payment.to_f + driver.holidays_payment.to_f + driver.bonus.to_f, driver.total ] , :height => 20, :style => [nil, center_top_left_right, top_left_right, top_left_right, center_top_left_right, center_top_left_right, center_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right]
        end

        sheet.add_row ['','','', 'TOTAL', @warnens.sum(:non_holidays), @warnens.sum(:holidays), @warnens.sum('holidays + non_holidays'), @warnens.sum(:master_weight_loss), @warnens.sum(:weight_loss), @warnens.sum("master_weight_loss-weight_loss"), @warnens.sum(:master_accident), @warnens.sum(:accident),@warnens.sum("master_accident-accident"), @warnens.sum(:master_sparepart), @warnens.sum(:sparepart), @warnens.sum("master_sparepart-sparepart"), @warnens.sum(:master_bon), @warnens.sum(:bon), @warnens.sum("master_bon-bon"), @warnens.sum(:allowance), @warnens.sum(:master_saving), @warnens.sum(:saving_reduction), @warnens.sum(:saving), @warnens.sum("master_saving-saving_reduction+saving"), @warnens.sum("weight_loss+sparepart+accident+bon+saving+allowance"), @warnens.sum(:non_holidays_payment), @warnens.sum(:holidays_payment), @warnens.sum(:bonus), @warnens.sum("non_holidays_payment+holidays_payment+bonus"), @warnens.sum(:total) ] , :height => 20, :style => [nil, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_center_top_left_right_bottom, bold_center_top_left_right_bottom, bold_center_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom]
      end
    end

    if @helpers.any?
      p.workbook.add_worksheet(:name => "Kernet") do |sheet|
         bold = sheet.styles.add_style(:b => true)
        bold_top_left_right = sheet.styles.add_style(:b => true, :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :center, :vertical => :center} )

        top_left_right = sheet.styles.add_style(:border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :left} )
        center_top_left_right = sheet.styles.add_style(:border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :center} )
        number_top_left_right = sheet.styles.add_style(:format_code => "#,##0.00", :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right] }, :alignment => { :horizontal => :right} )
        bold_number_top_left_right_bottom = sheet.styles.add_style(:b => true, :format_code => "#,##0.00", :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right, :bottom] }, :alignment => { :horizontal => :right} )
        bold_center_top_left_right_bottom = sheet.styles.add_style(:b => true, :border => { :style => :thin, :color =>"00000000", :edges => [:top, :left, :right,:bottom] }, :alignment => { :horizontal => :center} )


        right = sheet.styles.add_style(:alignment => {:horizontal => :right})
        right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
        h1 = sheet.styles.add_style :b => true, :sz => 16
        h2 = sheet.styles.add_style :b => true, :sz => 14
        number = sheet.styles.add_style :format_code => "#,##0.00"
        wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

        sheet.add_row [''], :height => 20
        sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " - Divisi Marketing"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

        sheet.add_row [''], :height => 20
        sheet.add_row ['', "Gaji Kernet"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]
        sheet.add_row ['',"Bulan   : #{@date_period.strftime('%^B %Y')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]
        sheet.add_row ['',"Periode : #{@date_period.strftime('%d %B %Y')} s/d #{(@date_period.next_month - 1.day).strftime('%d %B %Y')}"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h2]

        sheet.add_row [''], :height => 20
        sheet.add_row ['','NO', 'NO.POL', 'NAMA', 'KEHADIRAN', '', '', 'KLAIM SUSUT', '', '', 'KLAIM KECELAKAAN', '', '', 'KLAIM ONDERDIL', 'POT', 'SISA', 'PINJAMAN', '', '', 'GANTUNGAN SANGU', 'TABUNGAN', '', '','', 'TOTAL POTONGAN', 'PENGHARGAAN KEHADIRAN', '', '', '', 'BIAYA JASA BERSIH' ] , :height => 20, :style => [nil, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right]
        sheet.add_row ['','', '', '', 'NON HLN', 'HLN', 'TOTAL HADIR', 'KLAIM', 'POT', 'SISA', 'KLAIM', 'POT', 'SISA', 'KLAIM', 'POT', 'SISA', 'JUMLAH', 'POT', 'SISA', 'GANTUNGAN SANGU', 'TABUNGAN AWAL', 'AMBIL TABUNGAN', 'TABUNGAN','TOTAL TABUNGAN', 'TOTAL POTONGAN', 'NON HLN', 'HLN', 'PREMI HADIR', 'TOTAL', 'BIAYA JASA BERSIH' ] , :height => 20, :style => [nil, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right, bold_top_left_right,bold_top_left_right, bold_top_left_right]

        sheet.merge_cells "B8:B9"
        sheet.merge_cells "C8:C9"
        sheet.merge_cells "D8:D9"
        sheet.merge_cells "E8:G8"
        sheet.merge_cells "H8:J8"
        sheet.merge_cells "K8:M8"
        sheet.merge_cells "N8:P8"
        sheet.merge_cells "Q8:S8"
        sheet.merge_cells "U8:X8"
        sheet.merge_cells "Z8:AC8"

        @helpers.order(:id).each_with_index do |driver, i|
         sheet.add_row ['',i+1, (driver.vehicle.current_id rescue ''), (driver.helper.name rescue ''), driver.non_holidays, driver.holidays, driver.holidays + driver.non_holidays, driver.master_weight_loss, driver.weight_loss, driver.master_weight_loss.to_f - driver.weight_loss.to_f, driver.master_accident, driver.accident, driver.master_accident.to_f - driver.accident.to_f, driver.master_sparepart, driver.sparepart, driver.master_sparepart.to_f - driver.sparepart.to_f, driver.master_bon, driver.bon, driver.master_bon.to_f - driver.bon.to_f, driver.allowance, driver.master_saving, driver.saving_reduction, driver.saving, driver.master_saving.to_f - driver.saving_reduction.to_f + driver.saving.to_f, driver.weight_loss.to_f + driver.sparepart.to_f + driver.accident.to_f + driver.bon.to_f + driver.saving.to_f + driver.allowance.to_f, driver.non_holidays_payment, driver.holidays_payment, driver.bonus, driver.non_holidays_payment.to_f + driver.holidays_payment.to_f + driver.bonus.to_f, driver.total ] , :height => 20, :style => [nil, center_top_left_right, top_left_right, top_left_right, center_top_left_right, center_top_left_right, center_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right, number_top_left_right,number_top_left_right, number_top_left_right]
        end

        sheet.add_row ['','','', 'TOTAL', @helpers.sum(:non_holidays), @helpers.sum(:holidays), @helpers.sum('holidays + non_holidays'), @helpers.sum(:master_weight_loss), @helpers.sum(:weight_loss), @helpers.sum("master_weight_loss-weight_loss"), @helpers.sum(:master_accident), @helpers.sum(:accident),@helpers.sum("master_accident-accident"), @helpers.sum(:master_sparepart), @helpers.sum(:sparepart), @helpers.sum("master_sparepart-sparepart"), @helpers.sum(:master_bon), @helpers.sum(:bon), @helpers.sum("master_bon-bon"), @helpers.sum(:allowance), @helpers.sum(:master_saving), @helpers.sum(:saving_reduction), @helpers.sum(:saving), @helpers.sum("master_saving-saving_reduction+saving"), @helpers.sum("weight_loss+sparepart+accident+bon+saving+allowance"), @helpers.sum(:non_holidays_payment), @helpers.sum(:holidays_payment), @helpers.sum(:bonus), @helpers.sum("non_holidays_payment+holidays_payment+bonus"), @helpers.sum(:total) ] , :height => 20, :style => [nil, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_center_top_left_right_bottom, bold_center_top_left_right_bottom, bold_center_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom, bold_number_top_left_right_bottom,bold_number_top_left_right_bottom, bold_number_top_left_right_bottom]
      end
    end
    p.use_autowidth = false
    p.use_shared_strings = true

    send_data(p.to_stream.read, :filename => filename, :type => :xls, :x_sendfile => true)
  end

  def taxinvoiceitems
    role = cek_roles 'Admin Keuangan'
    if role
      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
      @invoices = Invoice.where("(date > ? and date < ?) AND deleted = false", @startdate.to_date, @enddate.to_date).order(:customer_id)

      @section = "reports1"
      @where = "reports-taxinvoiceitems"
      render "taxinvoiceitems"
    else
      redirect_to root_path()
    end

  end

  def downloadexcelproductorder
    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
    @date = Date.today.strftime('%d-%m-%Y')

    filename = "productorder_" + @date.to_date.strftime('%d%m%Y') + ".xls"

    @productgroups = Productgroup.active.order(:name)

    green = Axlsx::Color.new :rgb => "FF00FF00"
    red = Axlsx::Color.new :rgb => "FFCC0033"

    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Productorder") do |sheet|

      bold = sheet.styles.add_style(:b => true)
      right = sheet.styles.add_style(:alignment => {:horizontal => :right})
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      h1 = sheet.styles.add_style :b => true, :sz => 16
      h2 = sheet.styles.add_style :b => true, :sz => 14
      h3_green = sheet.styles.add_style :color => green, :b => true
      h3_red = sheet.styles.add_style :color => red, :b => true
      number = sheet.styles.add_style :format_code => "#,##0.00"
      number_bold = sheet.styles.add_style :format_code => "#,##0.00", :b => true

      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"] , :height => 20, :widths => [:auto, :ignore], :style => [nil, bold]

      sheet.add_row [''], :height => 20
      sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Permintaan - Pembelian Stock: " + @startdate.to_date.strftime('%d %B %Y') + " - " + @enddate.to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

      # sheet.add_row [''], :height => 20
      # sheet.add_row ['','NO', 'TANGGAL', 'NAMA BARANG', 'NOPOL', 'JUMLAH', 'HARGA', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, right_bold, right_bold, right_bold]

      grand_total_order = 0
      grand_total_req = 0

      @productgroups.each do |group|

        @request = Productrequestitem.find_by_sql(["SELECT i.*, r.date from productrequestitems i inner join productrequests r on i.productrequest_id = r.id "+
                         "where i.product_id in (SELECT id FROM products WHERE productgroup_id = #{group.id}) " +
                         "AND r.date >= ? and r.date < ? AND r.deleted = false order by r.date", @startdate.to_date, @enddate.to_date + 1.day])

        @order = Productorderitem.find_by_sql(["SELECT i.*, r.date from productorderitems i inner join productorders r on i.productorder_id = r.id "+
                      "WHERE product_id in (SELECT id FROM products WHERE productgroup_id = ?) "+
                        "AND r.date >= ? and r.date < ? AND r.deleted = false order by r.date", group.id, @startdate.to_date, @enddate.to_date + 1.day])

        if (@request and @request.any?) or (@order and @order.any?)
          sheet.add_row [''], :height => 20
          sheet.add_row ['',group.name] , :height => 20, :style => [nil, h3_red]
          sheet.add_row [''], :height => 20
          sheet.add_row ['','NO', 'TANGGAL', 'NAMA BARANG', 'NOPOL', 'JUMLAH', 'HARGA', 'TOTAL' ] , :height => 20, :style => [nil, bold, bold, bold, bold, right_bold, right_bold, right_bold]

          total_order = 0
          total_req = 0

          sheet.add_row [''], :height => 20
          sheet.add_row ['', 'PERMINTAAN STOCK'] , :height => 20, :style => [nil, bold]
          @request.each_with_index do |item, i|
            if item.stockgiven > 0
              total_item = item.stockgiven * (item.total/item.quantity)
              total_req += total_item
              grand_total_req += total_item
              sheet.add_row ['',
                            i+1,
                            item.productrequest.date.strftime('%d-%m-%Y'),
                            item.product.name,
                            (item.productrequest.vehicle.current_id if !item.productrequest.vehicle_id.blank?),
                            to_currency_bank(item.stockgiven),
                            to_currency(item.total / item.quantity),
                            to_currency(total_item) ] , :height => 20, :style => [nil, nil, nil, nil, nil, number, number, number]
            end
          end
          sheet.add_row ['', '','','', '', '', '', to_currency(total_req)] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, nil, number_bold]

          sheet.add_row [''], :height => 20
          sheet.add_row ['', 'PEMBELIAN'] , :height => 20, :style => [nil, bold]
          @order.each_with_index do |item, i|
            total_order += item.total
            grand_total_order += item.total
            sheet.add_row ['',
                          i+1,
                          item.productorder.date.strftime('%d-%m-%Y'),
                          item.product.name,
                          (item.productorder.productrequest.vehicle.current_id if  !item.productorder.productrequest.blank? and !item.productorder.productrequest.vehicle_id.blank?),
                          item.quantity,
                          to_currency(item.price_per),
                          to_currency(item.total) ] , :height => 20, :style => [nil, nil, nil, nil, nil, number, number, number]
          end
          sheet.add_row ['', '','','', '', '', '', to_currency(total_order)] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, nil, number_bold]

          sheet.add_row ['', '','TOTAL','', '', '', '', to_currency(total_req + total_order)] , :height => 20, :style => [nil, nil, bold, nil, nil, nil, nil, number_bold]
        end
      end
      sheet.add_row [''], :height => 20
      sheet.add_row ['', '','','', '', '', 'Total Permintaan', to_currency(grand_total_req, 'Rp. ')] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, bold, h3_red]
      sheet.add_row ['', '','','', '', '', 'Total Pembelian', to_currency(grand_total_order, 'Rp. ')] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, bold, h3_red]

      p.use_autowidth = false
      p.use_shared_strings = true

      send_data(p.to_stream.read, :filename => filename, :type => :xls, :x_sendfile => true)
    end
  end

  def estimationincomeexpense
    role = cek_roles 'Admin Keuangan, Estimasi'

      # @is_superior = []
      # @is_kosongan = []
      # @is_foccon = []

      # superiors = Customer.where("name ~* '.*superior.*' or name ~* '.*indogreen.*' or name ~* '.*PRIORITY ONE.*' or name ~* '.*CORRIN.*' or name ~* '.*FOCCON INTERLITE.*' or name ~* '.*PRIMAVOST.*' or name ~* '.*corin.*' or name ~* '.*focon interlite.*'")
      # foccon = Customer.where("name ~* '.*focon interlite.*'")
      # kosongans = Customer.where("name ~* '.*kosongan.*'")

      # superiors.map do |superior|
      #   @is_superior.push(superior.id)
      # end

      # kosongans.map do |kosongan|
      #   @is_kosongan.push(kosongan.id)
      # end

      # foccon.map do |focon|
      #   @is_foccon.push(focon.id)
      #   end

      @tanktype = params[:tanktype]

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      # BKK
		  @invoices = Invoice.active.where("(date between ? and ?) AND invoices.id in (SELECT invoice_id FROM receipts where deleted = false)",@startdate.to_date,@enddate.to_date).order(:date)

      if @tanktype.present? and @tanktype != 'all'
        @invoices = @invoices.joins(:vehicle).where('platform_type = ?', @tanktype)
      end

      @customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Acidatama.*'").pluck(:id)

      @section = "estimationreport"
      @where = "estimationincomeexpense"
  end

  def estimationdashboard
    @date = Date.today.strftime('%d-%m-%Y')
    @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
    formatted_startdate = @startdate.to_date.strftime("%Y-%m-%d")
    formatted_enddate = @enddate.to_date.strftime("%Y-%m-%d")
		# Saldo Kas
		@saldoKas = to_currency(Setting.find_by_name("Saldo Kas Kantor").value.to_i) || 0

		# BKK
		@invoices = Invoice.active.where("(date between ? and ?) AND id in (SELECT invoice_id FROM receipts where deleted = false)",formatted_startdate,formatted_enddate)

		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		@total = estimation = 0
    @customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Acidatama.*'").pluck(:id)
	    @invoices.each do |invoice|
	      # qty = invoice.quantity
	      # qty -= invoice.receiptreturns.where(:deleted => false).sum(:quantity) if invoice.receiptreturns.where(:deleted => false).any?
	      #   if (invoice.route.price_per || 0) >= offset
	      #     estimation = qty * (invoice.route.price_per.to_i || 0)
	      #   else
	      #     estimation = qty * 25000 * (invoice.route.price_per.to_i || 0)
	      #   end

	      @total += invoice.get_estimation(offset,@customer_35)
	    end

	    @invoices = Invoice.active.where("(date between ? and ?) AND id not in (SELECT invoice_id FROM receipts where deleted = false)",formatted_startdate,formatted_enddate)
		@receipts = Receipt.active.where("created_at between ? and ?",formatted_startdate,formatted_enddate)

		@totalBkk = (@invoices.sum(:quantity)+@receipts.sum(:quantity)).to_f
		receipt = @receipts.sum(:quantity).to_f

		if @totalBkk == 0
			@persentaseBkk = 0
		else
			@persentaseBkk = receipt * 100
			@persentaseBkk /= @totalBkk
		end

		#BKM
		@invoicereturns = Invoicereturn.active.where("(date between ? and ?) AND id not in (SELECT id from invoicereturns where id in (SELECT invoicereturn_id FROM receiptreturns where deleted = false))",formatted_startdate,formatted_enddate)
		@receiptreturns = Receiptreturn.active.where("created_at between ? and ?",formatted_startdate,formatted_enddate)

		@totalBkm = (@invoicereturns.sum(:quantity)+@receiptreturns.sum(:quantity)).to_f
		receiptreturn = @receiptreturns.sum(:quantity).to_f
		if @totalBkm == 0
			@persentaseBkm = 0
		else
			@persentaseBkm = receiptreturn * 100
			@persentaseBkm /= @totalBkm
		end

		# Surat Jalan
		taxinvoiceitems = Taxinvoiceitem.active.where("date between ? and ?",formatted_startdate,formatted_enddate).count(:all)
		# taxgenericitems = Taxgenericitem.active.where("(date ? and ?)").count(:all)
		@totalDitagihkan = Taxinvoiceitem.active.where("(date between ? and ?) AND invoice_id IS NOT NULL",formatted_startdate, formatted_enddate).count(:all)

		@totalSuratjalan = taxinvoiceitems #+ taxgenericitems
		if @totalSuratjalan == 0
			@persentaseSuratJalan = 0
		else
			@persentaseSuratJalan = @totalDitagihkan.to_f * 100
			@persentaseSuratJalan /= @totalSuratjalan.to_f
		end

		# Invoice
		@totalInvoice = Taxinvoice.active.where("(date between ? and ?)",formatted_startdate,formatted_enddate).count(:all)
		@totalPaidinvoice = Taxinvoice.active.where("(date between ? and ?) AND paiddate is not null",formatted_startdate,formatted_enddate).count(:all)

		totalRupiahInvoice = Taxinvoice.active.where("(date between ? and ?)",formatted_startdate,formatted_enddate).sum(:total)
		totalRupiahPaidInvoice = Taxinvoice.active.where("(date between ? and ?) AND paiddate is not null",formatted_startdate,formatted_enddate).sum(:total)

		if totalRupiahInvoice == 0
			@persentaseInvoice = 0
		else
			@persentaseInvoice = (totalRupiahPaidInvoice.to_f / totalRupiahInvoice.to_f)*100
		end

		@invoicenotpaids = Taxinvoice.active.where("paiddate IS NULL").limit(100).order('period_end asc')

    @section = "estimationreport"
    @where = "estimationdashboard"

  end

  def shrinkreport
    role = cek_roles 'Admin Keuangan, Admin Auditor, Admin Penagihan'

    @startdate = params[:startdate] || Date.today.strftime('%d-%m-%Y')
    @enddate = params[:enddate] || Date.today.strftime('%d-%m-%Y')

#    @taxinvoiceitems = Taxinvoiceitem.where('date BETWEEN :startdate AND :enddate and deleted = false', {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:invoice_id)

		@taxinvoiceitems = Taxinvoiceitem.where('invoice_id in (SELECT id FROM invoices where date BETWEEN :startdate AND :enddate and deleted = false)', {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:invoice_id)

    respond_to :html

		@section = "reports2"
		@where = 'shrinkreport'
  end

  def driver_rit
    role = cek_roles 'Admin HRD, Admin Keuangan, Admin Operasional'
    if !role
      redirect_to "/"
      return false
    end
    # @reports = Invoice.where("id in (select invoice_id from receipts)").group('driver_id').select("driver_id, sum(quantity)")

    # @reports = Invoice.find_by_sql("select driver_id, d.name, sum(quantity) from invoices i join drivers d on d.id = i.driver_id where i.id in (select invoice_id from receipts) and date between '2021-12-01' and '2021-12-22' GROUP BY driver_id, d.name")
    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?


    @reports = Invoice.joins(:driver).where("invoices.id in (select invoice_id from receipts)").where("invoices.date between ? and ?",@startdate.to_date, @enddate.to_date).where("drivers.deleted = false").group("drivers.id").select("drivers.id, drivers.name, sum(quantity) as rit, count(invoices.id) as bkk").order('drivers.name')
    # render json: @reports
    @section = "reports2"
		@where = 'driver-rit'
  end

  def indexmonthlyreport_vehicle
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Keuangan'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @month = params[:month]
      @month = Date.today.month if @month.nil?

      @tanktype = params[:tanktype]

      @vehiclegroups= Vehiclegroup.where(:deleted => false).order(:name)

      # @vehicles = Vehicle.active.order(:current_id)

      # if @tanktype.present? and @tanktype != 'all'
      #   @vehicles = @vehicles.where('platform_type = ?', @tanktype)
      # end

      @section = "reports2"
      @where = "annualreport-vehicle"
      # render "indexannualreport-vehicle"

      # render json: @vehiclegroups
      # return false

    else
      redirect_to root_path()
    end


  end

  def incomeexpenseestimation_vehicle
    role = cek_roles 'Admin Operasional, Admin HRD, Admin Keuangan'
    if role
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @month = params[:month]
      @month = Date.today.month if @month.nil?

      @vehiclegroups= Vehiclegroup.where(:deleted => false).order(:name)
      @vehicles = Vehicle.active.all(:order=>:current_id)

      @section = "reports2"
      @where = "incomeexpenseestimation_vehicle"
      # render "indexannualreport-vehicle"

      # render json: @vehiclegroups
      # return false

    else
      redirect_to root_path()
    end
  end

  def unpaid_invoice

    role = cek_roles 'Admin Keuangan, Auditor, Admin Penagihan'

    if role

      @month = params[:month]
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @day = "01"
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @monthEnd = params[:monthEnd]
      @monthEnd = "%02d" % Date.today.month.to_s if @monthEnd.nil?
      @dayEnd = getlastday (@monthEnd.to_s)
      @yearEnd = params[:yearEnd]
      @yearEnd = Date.today.year if @yearEnd.nil?

      @taxinvoices = Taxinvoice.active.joins(:customer)

      # @taxinvoices = @taxinvoices.where("paiddate is null AND to_char(date, 'DD-MM-YYYY') BETWEEN ? AND ?", "#{@day}-#{@month}-#{@year}","#{@dayEnd}-#{@monthEnd}-#{@yearEnd}")
      @taxinvoices = @taxinvoices.where("paiddate is null AND date BETWEEN ? AND ?", "#{@year}-#{@month}-#{@day}-","#{@yearEnd}-#{@monthEnd}-#{@dayEnd}")
      # @taxinvoices = @taxinvoices.where("paiddate is null AND to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}")

      @customers = Customer.active.where("id in (?)", @taxinvoices.pluck('customer_id')).order(:name)

      @customer_id = params[:customer_id]

      if @customer_id.present?
        @taxinvoices = @taxinvoices.where("customer_id = ?", @customer_id)
      end

      if params[:due_date_order].present?
        if params[:due_date_order] == "asc"
          @taxinvoices = @taxinvoices.order("((case when sentdate is not null then sentdate else date end) + (interval '1' day * COALESCE(customers.terms_of_payment_in_days,0))) asc")
        elsif params[:due_date_order] == "desc"
          @taxinvoices = @taxinvoices.order("((case when sentdate is not null then sentdate else date end) + (interval '1' day * COALESCE(customers.terms_of_payment_in_days,0))) desc")
        end
      else
        @taxinvoices = @taxinvoices.order(:long_id)
      end
      # render json: @taxinvoices
      @section = "reports2"
      @where = "reports-unpaidinvoice"

    else
      redirect_to root_path()
    end
  end

  def paid_invoice

    role = cek_roles 'Admin Keuangan, Auditor, Admin Penagihan'

    if role

      @month = params[:month]
      @month = "%02d" % Date.today.month.to_s if @month.nil?
      @day = "01"
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @monthEnd = params[:monthEnd]
      @monthEnd = "%02d" % Date.today.month.to_s if @monthEnd.nil?
      @dayEnd = getlastday (@monthEnd.to_s)
      @yearEnd = params[:yearEnd]
      @yearEnd = Date.today.year if @yearEnd.nil?

      @taxinvoices = Taxinvoice.active.joins(:customer)

      # @taxinvoices = @taxinvoices.where("paiddate is null AND to_char(date, 'DD-MM-YYYY') BETWEEN ? AND ?", "#{@day}-#{@month}-#{@year}","#{@dayEnd}-#{@monthEnd}-#{@yearEnd}")
      @taxinvoices = @taxinvoices.where("paiddate is not null AND date BETWEEN ? AND ?", "#{@year}-#{@month}-#{@day}-","#{@yearEnd}-#{@monthEnd}-#{@dayEnd}")

      @customer = Customer.find(params[:customer_id]) rescue nil

      if @customer.present?
        @taxinvoices = @taxinvoices.where("customer_id = ?", @customer.id)
      end

      if params[:due_date_order].present?
        if params[:due_date_order] == "asc"
          @taxinvoices = @taxinvoices.order("((case when sentdate is not null then sentdate else date end) + (interval '1' day * COALESCE(customers.terms_of_payment_in_days,0))) asc")
        elsif params[:due_date_order] == "desc"
          @taxinvoices = @taxinvoices.order("((case when sentdate is not null then sentdate else date end) + (interval '1' day * COALESCE(customers.terms_of_payment_in_days,0))) desc")
        end
      else
        @taxinvoices = @taxinvoices.order(:long_id)
      end
      # render json: @taxinvoices
      @section = "reports2"
      @where = "reports-paidinvoice"

    else
      redirect_to root_path()
    end
  end

  def estimation_event_expense_backup
    role = cek_roles 'Admin Keuangan'
    if role
      offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      global_sangu = 0
      global_solar = 0
      global_tambahan = 0
      global_tol_asdp = 0
      global_invoice_total = 0
      global_total_estimation = 0

      @events = Event.active.where("start_date between ? and ?", @startdate.to_date, @enddate.to_date).map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        invoices = event.invoices.active.pluck("route_id")

        sangu = 0
        solar = 0
        tambahan = 0
        tol_asdp = 0
        invoice_total = 0
        total_estimation = 0
        total_quantity = 0
        customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Acidatama.*'").pluck(:id)
        invoice_summary = event.invoices.active.map do |invoice|
          quantity = invoice.quantity - (invoice.receiptreturns.where(:deleted => false).sum(:quantity).to_i)
          if price_per >= offset
            estimation = quantity * price_per
          elsif customer_35.include? invoice.customer_id
            estimation = quantity * 20000 * price_per
          elsif(invoice.invoicetrain && invoice.isotank_id.to_i != 0 && price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage   dibuat 20,000 kg
            estimation = quantity * 20000 * price_per
          else
            estimation = quantity * 25000 * price_per
          end

          sangu += invoice.driver_allowance.to_i + invoice.helper_allowance.to_i
          solar += invoice.gas_allowance.to_i
          tambahan += invoice.misc_allowance.to_i
          tol_asdp += invoice.tol_fee.to_i + invoice.ferry_fee.to_i
          invoice_total += invoice.total.to_i
          total_estimation += estimation

          total_quantity += quantity

          {
            bkk_id: invoice.id,
            quantity: invoice.quantity,
            route_id: invoice.route_id,
            estimation: estimation
          }
        end

        description = "Rit ##{event.id}: #{route.name rescue nil}"
        global_sangu = 0
        global_solar += solar
        global_tambahan += tambahan
        global_tol_asdp += tol_asdp
        global_invoice_total += invoice_total
        global_total_estimation += total_estimation
        {
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          invoices: invoice_summary,
          sangu: sangu,
          solar: solar,
          tambahan: tambahan,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: total_estimation,
          description: description,
          start_date: event.start_date
        }
      end
      @summary = {
        global_solar: global_solar ,
        global_tambahan: global_tambahan ,
        global_tol_asdp: global_tol_asdp ,
        global_invoice_total: global_invoice_total ,
        global_total_estimation: global_total_estimation ,
      }
      @section = "estimationreport"
      @where = "estimation_event_invoice"
      # render json: @events
      # render "estimation"
    else
      redirect_to root_path()
    end

  end

  def estimation_event_expense_v1
    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role
      offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

      #marketings
      @user_id = params[:user_id]

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @customer_id = params[:customer_id]
      @routetrain_id = params[:routetrain_id]

      @customers = Customer.where('id in (select customer_id from events where deleted = false and start_date between ? and ?)', @startdate.to_date, @enddate.to_date).order(:name)

      @eventsa = Event.active.where("cancelled = false AND start_date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date).order(:start_date)

      @transporttype = params[:transporttype]
      @tanktype = params[:tanktype]

      @createdat = params[:createdat]

      if @createdat.present? and @createdat != 'all'
        if @createdat == "08.00-12.00"
          # Filtering records between 08:00 - 12:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 0, 12)
        else
          # Filtering records between 12:00 - 17:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 12, 23)
        end
      end
      # render json: @eventsa.to_sql
      # return false

      if @customer_id.present? and @customer_id != 'all'
        @eventsa = @eventsa.where('customer_id = ?', @customer_id)
        @customers = Customer.active.reorder(:name)
      end

      if @transporttype.present? and @transporttype != 'all'
        if @transporttype == 'RORO'
          @eventsa = @eventsa.where('invoiceship = true')
        elsif @transporttype == 'LOSING'
          @eventsa = @eventsa.where('losing = true')
        else
          if @transporttype == 'KERETA'
            @eventsa = @eventsa.where('invoicetrain = true')
          else
            @eventsa = @eventsa.where('invoicetrain = false')
          end
        end
      end

      if @tanktype.present? and @tanktype != 'all'
        @eventsa = @eventsa.where('tanktype = ?', @tanktype)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:office_id].present? && params[:office_id] != 'all'
        @eventsa = @eventsa.where('office_id = ?', params[:office_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:operator_id].present? && params[:operator_id] != 'all'
        @eventsa = @eventsa.where(operator_id: params[:operator_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:routetrain_id].present? && params[:routetrain_id] != 'all'
        @eventsa = @eventsa.where(routetrain_id: params[:routetrain_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @user_id.present?
        @eventsa = @eventsa.where(user_id: params[:user_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      # render json: params
      # return false

      global_supir = 0
      global_kernet = 0
      global_solar = 0
      global_tambahan = 0
      global_tol_asdp = 0
      global_premi = 0
      global_invoice_total = 0
      global_total_estimation = 0
      global_ppn_total = 0
      global_total_real = 0 
      solar_price = Setting.find_by_name("Harga Solar").value.to_i
      customer_35 = Customer.active.where("name ~* '.*Acidatama.*'").pluck(:id)

      # render json: @eventsa

      @events = @eventsa.map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0

        # if price_per >= offset
        #   estimation = quantity * price_per
        # elsif customer_35.include? event.customer_id
        #   estimation = quantity * 20000 * price_per
        # elsif(price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage   dibuat 20,000 kg
        #   estimation = quantity * event_tonage * price_per
        # else
        #   estimation = quantity * event_tonage * price_per
        # end

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        ppn = 0
        if event.customer.gst_percentage > 0
          ppn = estimation * event.customer.gst_percentage.to_i / 100
        end

        realization = 0
        invoices = Invoice.active.where('event_id = ? AND invoice_id is null AND id not in(select invoice_id from invoicereturns where deleted = false)', event.id).map do |bkk|

          bkk_route = bkk.route
          bkk_price_per = bkk_route.price_per.to_i rescue 0
          est_bkk = 0

          offset_bkk = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
          if bkk_price_per >= offset_bkk
            est_bkk = bkk_price_per
          else
            est_bkk = bkk.event.estimated_tonage.to_i * bkk_price_per
          end

          realization += est_bkk

        end

        # check target
        @target = params[:target]
        if @target.present? && @target != 'all'
          case @target
          when "Proses"
            next if estimation == realization # Skip if estimation equals realization
          when "Tercapai"
            next if estimation != realization # Skip if estimation is not equal to realization
          end
        end

        global_supir += supir
        global_kernet += kernet
        global_solar += solar
        global_tambahan += tambahan
        global_tol_asdp += tol_asdp
        global_premi += premi
        global_invoice_total += invoice_total
        global_ppn_total += ppn
        global_total_estimation += estimation
        global_total_real += realization

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>"
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"

        {
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          username: event.user.username,
          solar: solar,
          ppn: ppn,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id,
          realization: realization
        }
      end.compact

      @summary = {
        global_supir: global_supir ,
        global_kernet: global_kernet ,
        global_solar: global_solar ,
        global_tambahan: global_tambahan ,
        global_tol_asdp: global_tol_asdp ,
        global_premi: global_premi ,
        global_invoice_total: global_invoice_total ,
        global_ppn_total: global_ppn_total ,
        global_total_estimation: global_total_estimation ,
        global_total_real: global_total_real ,
      }
      @section = "estimationreport"
      @where = "estimation_event_invoice"
      # render json: @events
      # return false
      # render "estimation"
    else
      redirect_to root_path()
    end

  end

  def estimation_event_expense
    @pagetitle = 'Estimasi BKK vs DO'
    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role
      offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

      #marketings
      @user_id = params[:user_id]

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      #check how many months
      @number_of_months = 0
      if @startdate && @enddate
        months = []
        current_date = @startdate.to_date
        while current_date <= @enddate.to_date
          months << current_date.strftime('%Y-%m')
          current_date = current_date.next_month
        end
        @number_of_months = months.uniq.count
      end

      # Get contracts
      contracts = Contract.active.where("date_start BETWEEN ? AND ? OR date_end BETWEEN ? AND ? OR ? BETWEEN date_start AND date_end OR ? BETWEEN date_start AND date_end", @startdate.to_date, @enddate.to_date, @startdate.to_date, @enddate.to_date, @startdate.to_date, @enddate.to_date)

      exevents = []
      contracts.each do |contract|
        if contract.contract_type == "period"
          contract_events = Event.active.where(customer_id: contract.customer_id).where("start_date BETWEEN ? AND ?", contract.date_start, contract.date_end).pluck(:id)
        elsif contract.contract_type == "route"
          contract_routes = Route.active.where(contract_id: contract.id).pluck(:id)
          contract_events = Event.active.where(customer_id: contract.customer_id, route_id: contract_routes).where("start_date BETWEEN ? AND ?", contract.date_start, contract.date_end).pluck(:id)
        end
        exevents.push(contract_events)
      end
      exevents = exevents.flatten.compact.uniq
      exevents = [0] if exevents.blank?

      # render json: exevents
      # return false

      @customer_id = params[:customer_id]
      @commodity_id = params[:commodity_id]

      @customers = Customer.where('id in (select customer_id from events where deleted = false and start_date between ? and ?)', @startdate.to_date, @enddate.to_date).order(:name)

      @eventsa = Event.active.where("cancelled = false AND start_date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date).order(:start_date)

      @transporttype = params[:transporttype]
      @tanktype = params[:tanktype]

      @createdat = params[:createdat]

      

      if @createdat.present? and @createdat != 'all'
        if @createdat == "08.00-12.00"
          # Filtering records between 08:00 - 12:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 0, 12)
          @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
        else
          # Filtering records between 12:00 - 17:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 12, 23)
          @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
        end
      end

      if @customer_id.present? and @customer_id != 'all'
        @eventsa = @eventsa.where('customer_id = ?', @customer_id)
        @customers = Customer.active.reorder(:name)
      end

      if @commodity_id.present? and @commodity_id != 'all'
        @eventsa = @eventsa.where('commodity_id = ?', @commodity_id)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @transporttype.present? and @transporttype != 'all'
        if @transporttype == 'RORO'
          @eventsa = @eventsa.where('invoiceship = true')
        elsif @transporttype == 'LOSING'
          @eventsa = @eventsa.where('losing = true')
        else
          if @transporttype == 'KERETA'
            @eventsa = @eventsa.where('invoicetrain = true')
          else
            @eventsa = @eventsa.where('invoicetrain = false')
          end
        end
      end

      if @tanktype.present? and @tanktype != 'all'
        @eventsa = @eventsa.where('tanktype = ?', @tanktype)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:office_id].present? && params[:office_id] != 'all'
        @eventsa = @eventsa.where('office_id = ?', params[:office_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:operator_id].present? && params[:operator_id] != 'all'
        @eventsa = @eventsa.where(operator_id: params[:operator_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:routetrain_id].present? && params[:routetrain_id] != 'all'
        @eventsa = @eventsa.where(routetrain_id: params[:routetrain_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @user_id.present?
        @eventsa = @eventsa.where(user_id: params[:user_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      global_supir = 0
      global_kernet = 0
      global_solar = 0
      global_tambahan = 0
      global_tol_asdp = 0
      global_premi = 0
      global_invoice_total = 0
      global_ppn_total = 0
      global_total_estimation = 0
      global_total_real = 0 
      solar_price = Setting.find_by_name("Harga Solar").value.to_i
      customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)

      # render json: @eventsa.where("id NOT IN (?)", exevents).to_sql
      # return false

      @events = @eventsa.where("id NOT IN (?)", exevents).map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0

        # if price_per >= offset
        #   estimation = quantity * price_per
        # elsif customer_35.include? event.customer_id
        #   estimation = quantity * 20000 * price_per
        # elsif(price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage   dibuat 20,000 kg
        #   estimation = quantity * event_tonage * price_per
        # else
        #   estimation = quantity * event_tonage * price_per
        # end

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        ppn = 0
        if event.customer.gst_percentage > 0
          ppn = estimation * event.customer.gst_percentage.to_i / 100
        end

        realization = 0
        invoices = Invoice.active.where('event_id = ? AND invoice_id is null AND id not in(select invoice_id from invoicereturns where deleted = false)', event.id).map do |bkk|

          bkk_route = bkk.route
          bkk_price_per = bkk_route.price_per.to_i rescue 0
          est_bkk = 0

          offset_bkk = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
          if bkk_price_per >= offset_bkk
            est_bkk = bkk_price_per
          else
            est_bkk = bkk.event.estimated_tonage.to_i * bkk_price_per
          end

          realization += est_bkk

        end

        # check target
        @target = params[:target]
        if @target.present? && @target != 'all'
          case @target
          when "Proses"
            next if estimation == realization # Skip if estimation equals realization
          when "Tercapai"
            next if estimation != realization # Skip if estimation is not equal to realization
          end
        end
        
        global_supir += supir
        global_kernet += kernet
        global_solar += solar
        global_tambahan += tambahan
        global_tol_asdp += tol_asdp
        global_premi += premi
        global_invoice_total += invoice_total
        global_ppn_total += ppn
        global_total_estimation += estimation
        global_total_real += realization

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>"
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"

        {
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          username: event.user.username,
          kernet: kernet,
          solar: solar,
          ppn: ppn,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id,
          realization: realization
        }
      end
      
      @summary = {
        global_supir: global_supir ,
        global_kernet: global_kernet ,
        global_solar: global_solar ,
        global_tambahan: global_tambahan ,
        global_tol_asdp: global_tol_asdp ,
        global_premi: global_premi ,
        global_invoice_total: global_invoice_total ,
        global_ppn_total: global_ppn_total ,
        global_total_estimation: global_total_estimation ,
        global_total_real: global_total_real ,
      }

      # render json: @events
      # return false

      # DO in contracts
      global_contract_supir = 0
      global_contract_kernet = 0
      global_contract_solar = 0
      global_contract_tambahan = 0
      global_contract_tol_asdp = 0
      global_contract_premi = 0
      global_contract_invoice_total = 0
      global_contract_ppn_total = 0
      global_contract_total_estimation = 0
      global_contract_total_real = 0 
      contract_customers = []
      contract_used = []

      @contract_events = []

      # render json: @contract_events

      contracts.each do |contract|
        if contract.contract_type == "period"
          events = Event.active.where(customer_id: contract.customer_id).where("start_date BETWEEN ? AND ? AND start_date BETWEEN ? AND ?", contract.date_start, contract.date_end, @startdate.to_date, @enddate.to_date)
        elsif contract.contract_type == "route"
          routes = Route.active.where(contract_id: contract.id, price_per_type: 'KONTRAK').pluck(:id)
          events = Event.active.where(customer_id: contract.customer_id, route_id: routes).where("start_date BETWEEN ? AND ? AND start_date BETWEEN ? AND ?", contract.date_start, contract.date_end, @startdate.to_date, @enddate.to_date)
        end

        # Filter
        # if @customer_id.present? and @customer_id != 'all'
        #   events = events.where('customer_id = ?', @customer_id)
        # end

        if @transporttype.present? and @transporttype != 'all'
          if @transporttype == 'RORO'
            events = events.where('invoiceship = true')
          elsif @transporttype == 'LOSING'
            events = events.where('losing = true')
          else
            if @transporttype == 'KERETA'
              events = events.where('invoicetrain = true')
            else
              events = events.where('invoicetrain = false')
            end
          end
        end

        if @tanktype.present? and @tanktype != 'all'
          events = events.where('tanktype = ?', @tanktype)
        end

        if params[:office_id].present? && params[:office_id] != 'all'
          events = events.where('office_id = ?', params[:office_id])
        end

        if params[:operator_id].present? && params[:operator_id] != 'all'
          # events = events.where(operator_id: params[:operator_id])
          events = events.where('operator_id = ?', params[:operator_id])
        end

        if params[:routetrain_id].present? && params[:routetrain_id] != 'all'
          # events = events.where(routetrain_id: params[:routetrain_id])
          events = events.where('routetrain_id = ?', params[:routetrain_id])
        end

        if events.present?
          events.each do |event|
            route = event.route
            price_per = route.price_per.to_i rescue 0
            price_per_type = route.price_per_type rescue 'KG'
            route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
            quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

            supir = route_allowance.driver_trip.to_i rescue 0
            kernet = route_allowance.helper_trip.to_i rescue 0
            premi = route.bonus.to_i rescue 0
            solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
            tambahan = route_allowance.misc_allowance.to_i rescue 0
            tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
            invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

            quantity = event.qty.to_i rescue 0
            event_price_per_type = event.price_per_type rescue 'KG'
            event_tonage = event.estimated_tonage.to_i rescue 0

            if contract_used.include? contract.id
              estimation = 0
            else
              estimation = contract.total.to_i rescue 0
              estimation = estimation * @number_of_months
              contract_used.push(contract.id)
            end

            ppn = 0
            if event.customer.gst_percentage > 0
              ppn = estimation * event.customer.gst_percentage.to_i / 100
            end
            
            realization = 0
            invoices = Invoice.active.where('event_id = ? AND invoice_id is null AND id not in(select invoice_id from invoicereturns where deleted = false)', event.id).map do |bkk|
    
              bkk_route = bkk.route
              bkk_price_per = bkk_route.price_per.to_i rescue 0
              est_bkk = 0
    
              offset_bkk = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
              if bkk_price_per >= offset_bkk
                est_bkk = bkk_price_per
              else
                est_bkk = bkk.event.estimated_tonage.to_i * bkk_price_per
              end
    
              realization += est_bkk
    
            end

            global_contract_supir += supir
            global_contract_kernet += kernet
            global_contract_solar += solar
            global_contract_tambahan += tambahan
            global_contract_tol_asdp += tol_asdp
            global_contract_premi += premi
            global_contract_invoice_total += invoice_total
            global_contract_ppn_total += ppn
            global_contract_total_estimation += estimation
            global_contract_total_real += realization

            description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>"
            description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"

            @contract_events.push({
              route_name: (route.name rescue "Kosong"),
              route_price: (route.price_per rescue "Kosong"),
              route_id: event.route_id,
              tanktype: event.tanktype,
              office: (event.office.abbr rescue "Kosong"),
              supir: supir,
              username: event.user.username,
              kernet: kernet,
              solar: solar,
              ppn: ppn,
              tambahan: tambahan,
              premi_allowance: premi,
              tol_asdp: tol_asdp,
              invoice_total: invoice_total,
              total_estimation: estimation,
              description: description.html_safe,
              start_date: event.start_date,
              created_at: event.created_at,
              route_train: (event.routetrain.name rescue "Kosong"),
              route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
              route_train_id: event.routetrain_id,
              realization: realization
            })
          end
        end
      end

      # @contract_events = @eventsa.where(id: exevents).map do |event|
      #   route = event.route
      #   price_per = route.price_per.to_i rescue 0
      #   price_per_type = route.price_per_type rescue 'KG'
      #   route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
      #   quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

      #   supir = route_allowance.driver_trip.to_i rescue 0
      #   kernet = route_allowance.helper_trip.to_i rescue 0
      #   premi = route.bonus.to_i rescue 0
      #   solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
      #   tambahan = route_allowance.misc_allowance.to_i rescue 0
      #   tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
      #   invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

      #   quantity = event.qty.to_i rescue 0
      #   event_price_per_type = event.price_per_type rescue 'KG'
      #   event_tonage = event.estimated_tonage.to_i rescue 0

      #   if contract_customers.include? event.customer_id
      #     estimation = 0
      #   else
      #     contract = contracts.where(customer_id: event.customer_id).first
      #     estimation = contract.total.to_i rescue 0
      #     contract_customers.push(event.customer_id)
      #   end

      #   global_contract_supir += supir
      #   global_contract_kernet += kernet
      #   global_contract_solar += solar
      #   global_contract_tambahan += tambahan
      #   global_contract_tol_asdp += tol_asdp
      #   global_contract_premi += premi
      #   global_contract_invoice_total += invoice_total
      #   global_contract_total_estimation += estimation


      #   description = "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
      #   {
      #     route_name: (route.name rescue "Kosong"),
      #     route_price: (route.price_per rescue "Kosong"),
      #     route_id: event.route_id,
      #     tanktype: event.tanktype,
      #     office: (event.office.abbr rescue "Kosong"),
      #     supir: supir,
      #     kernet: kernet,
      #     solar: solar,
      #     tambahan: tambahan,
      #     premi_allowance: premi,
      #     tol_asdp: tol_asdp,
      #     invoice_total: invoice_total,
      #     total_estimation: estimation,
      #     description: description,
      #     start_date: event.start_date,
      #     route_train: (event.routetrain.name rescue "Kosong"),
      #     route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
      #     route_train_id: event.routetrain_id
      #   }
      # end

      # render json: @contract_events

      @contract_summary = {
        global_supir: global_contract_supir ,
        global_kernet: global_contract_kernet ,
        global_solar: global_contract_solar ,
        global_tambahan: global_contract_tambahan ,
        global_tol_asdp: global_contract_tol_asdp ,
        global_premi: global_contract_premi ,
        global_invoice_total: global_contract_invoice_total ,
        global_ppn_total: global_contract_ppn_total ,
        global_total_estimation: global_contract_total_estimation ,
        global_total_real: global_contract_total_real ,
      }

      # Grandtotal
      @grandtotal_supir = global_supir + global_contract_supir
      @grandtotal_kernet = global_kernet + global_contract_kernet
      @grandtotal_solar = global_solar + global_contract_solar
      @grandtotal_tambahan = global_tambahan + global_contract_tambahan
      @grandtotal_tol_asdp = global_tol_asdp + global_contract_tol_asdp
      @grandtotal_premi = global_premi + global_contract_premi
      @grandtotal_invoice_total = global_invoice_total + global_contract_invoice_total
      @grandtotal_ppn_total = global_ppn_total + global_contract_ppn_total 
      @grandtotal_total_estimation = global_total_estimation + global_contract_total_estimation
      @grandtotal_total_real = global_total_real + global_contract_total_real

      @section = "estimationreport"
      @where = "estimation_event_invoice"
    else
      redirect_to root_path()
    end

  end

  def estimation_event_expense_cancelled
    @pagetitle = 'Estimasi BKK vs DO'
    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role
      offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

      #marketings
      @user_id = params[:user_id]

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      # Get contracts
      contracts = Contract.active.where("date_start BETWEEN ? AND ? OR date_end BETWEEN ? AND ? OR ? BETWEEN date_start AND date_end OR ? BETWEEN date_start AND date_end", @startdate.to_date, @enddate.to_date, @startdate.to_date, @enddate.to_date, @startdate.to_date, @enddate.to_date)

      exevents = []
      contracts.each do |contract|
        if contract.contract_type == "period"
          contract_events = Event.active.where(customer_id: contract.customer_id).where("start_date BETWEEN ? AND ?", contract.date_start, contract.date_end).pluck(:id)
        elsif contract.contract_type == "route"
          contract_routes = Route.active.where(contract_id: contract.id).pluck(:id)
          contract_events = Event.where('cancelled = true').where(customer_id: contract.customer_id, route_id: contract_routes).where("start_date BETWEEN ? AND ?", contract.date_start, contract.date_end).pluck(:id)
        end
        exevents.push(contract_events)
      end
      exevents = exevents.flatten.compact.uniq
      exevents = [0] if exevents.blank?

      # render json: exevents
      # return false

      @customer_id = params[:customer_id]
      @commodity_id = params[:commodity_id]

      @customers = Customer.where('id in (select customer_id from events where deleted = false and start_date between ? and ?)', @startdate.to_date, @enddate.to_date).order(:name)

      @eventsa = Event.where("(deleted = true OR cancelled = true) AND start_date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date).order(:start_date)

      @transporttype = params[:transporttype]
      @tanktype = params[:tanktype]

      @createdat = params[:createdat]

      if @createdat.present? and @createdat != 'all'
        if @createdat == "08.00-12.00"
          # Filtering records between 08:00 - 12:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 0, 12)
          @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
        else
          # Filtering records between 12:00 - 17:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 12, 23)
          @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
        end
      end

      if @customer_id.present? and @customer_id != 'all'
        @eventsa = @eventsa.where('customer_id = ?', @customer_id)
        @customers = Customer.active.reorder(:name)
      end

      if @commodity_id.present? and @commodity_id != 'all'
        @eventsa = @eventsa.where('commodity_id = ?', @commodity_id)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @transporttype.present? and @transporttype != 'all'
        if @transporttype == 'RORO'
          @eventsa = @eventsa.where('invoiceship = true')
        elsif @transporttype == 'LOSING'
          @eventsa = @eventsa.where('losing = true')
        else
          if @transporttype == 'KERETA'
            @eventsa = @eventsa.where('invoicetrain = true')
          else
            @eventsa = @eventsa.where('invoicetrain = false')
          end
        end
      end

      if @tanktype.present? and @tanktype != 'all'
        @eventsa = @eventsa.where('tanktype = ?', @tanktype)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:office_id].present? && params[:office_id] != 'all'
        @eventsa = @eventsa.where('office_id = ?', params[:office_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:operator_id].present? && params[:operator_id] != 'all'
        @eventsa = @eventsa.where(operator_id: params[:operator_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:routetrain_id].present? && params[:routetrain_id] != 'all'
        @eventsa = @eventsa.where(routetrain_id: params[:routetrain_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @user_id.present?
        @eventsa = @eventsa.where(user_id: params[:user_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      global_supir = 0
      global_kernet = 0
      global_solar = 0
      global_tambahan = 0
      global_tol_asdp = 0
      global_premi = 0
      global_invoice_total = 0
      global_ppn_total = 0
      global_total_estimation = 0
      global_total_real = 0 
      solar_price = Setting.find_by_name("Harga Solar").value.to_i
      customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)

      # render json: @eventsa.where("id NOT IN (?)", exevents).to_sql
      # return false

      @events = @eventsa.where("id NOT IN (?)", exevents).map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0

        # if price_per >= offset
        #   estimation = quantity * price_per
        # elsif customer_35.include? event.customer_id
        #   estimation = quantity * 20000 * price_per
        # elsif(price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage   dibuat 20,000 kg
        #   estimation = quantity * event_tonage * price_per
        # else
        #   estimation = quantity * event_tonage * price_per
        # end

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        ppn = 0
        if event.customer.gst_percentage > 0
          ppn = estimation * event.customer.gst_percentage.to_i / 100
        end

        realization = 0
        invoices = Invoice.active.where('event_id = ? AND invoice_id is null AND id not in(select invoice_id from invoicereturns where deleted = false)', event.id).map do |bkk|

          bkk_route = bkk.route
          bkk_price_per = bkk_route.price_per.to_i rescue 0
          est_bkk = 0

          offset_bkk = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
          if bkk_price_per >= offset_bkk
            est_bkk = bkk_price_per
          else
            est_bkk = bkk.event.estimated_tonage.to_i * bkk_price_per
          end

          realization += est_bkk

        end

        # check target
        @target = params[:target]
        if @target.present? && @target != 'all'
          case @target
          when "Proses"
            next if estimation == realization # Skip if estimation equals realization
          when "Tercapai"
            next if estimation != realization # Skip if estimation is not equal to realization
          end
        end
        
        global_supir += supir
        global_kernet += kernet
        global_solar += solar
        global_tambahan += tambahan
        global_tol_asdp += tol_asdp
        global_premi += premi
        global_invoice_total += invoice_total
        global_ppn_total += ppn
        global_total_estimation += estimation
        global_total_real += realization

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>"
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"

        {
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          username: event.user.username,
          kernet: kernet,
          solar: solar,
          ppn: ppn,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id,
          realization: realization,
          reject_reason: event.reject_reason
        }
      end
      
      @summary = {
        global_supir: global_supir ,
        global_kernet: global_kernet ,
        global_solar: global_solar ,
        global_tambahan: global_tambahan ,
        global_tol_asdp: global_tol_asdp ,
        global_premi: global_premi ,
        global_invoice_total: global_invoice_total ,
        global_ppn_total: global_ppn_total ,
        global_total_estimation: global_total_estimation ,
        global_total_real: global_total_real ,
      }

      # render json: @events
      # return false

      # DO in contracts
      global_contract_supir = 0
      global_contract_kernet = 0
      global_contract_solar = 0
      global_contract_tambahan = 0
      global_contract_tol_asdp = 0
      global_contract_premi = 0
      global_contract_invoice_total = 0
      global_contract_ppn_total = 0
      global_contract_total_estimation = 0
      global_contract_total_real = 0 
      contract_customers = []
      contract_used = []

      @contract_events = []

      # render json: @contract_events

      contracts.each do |contract|
        if contract.contract_type == "period"
          events = Event.active.where(customer_id: contract.customer_id).where("start_date BETWEEN ? AND ? AND start_date BETWEEN ? AND ?", contract.date_start, contract.date_end, @startdate.to_date, @enddate.to_date)
        elsif contract.contract_type == "route"
          routes = Route.active.where(contract_id: contract.id, price_per_type: 'KONTRAK').pluck(:id)
          events = Event.active.where(customer_id: contract.customer_id, route_id: routes).where("start_date BETWEEN ? AND ? AND start_date BETWEEN ? AND ?", contract.date_start, contract.date_end, @startdate.to_date, @enddate.to_date)
        end

        # Filter
        # if @customer_id.present? and @customer_id != 'all'
        #   events = events.where('customer_id = ?', @customer_id)
        # end

        if @transporttype.present? and @transporttype != 'all'
          if @transporttype == 'RORO'
            events = events.where('invoiceship = true')
          elsif @transporttype == 'LOSING'
            events = events.where('losing = true')
          else
            if @transporttype == 'KERETA'
              events = events.where('invoicetrain = true')
            else
              events = events.where('invoicetrain = false')
            end
          end
        end

        if @tanktype.present? and @tanktype != 'all'
          events = events.where('tanktype = ?', @tanktype)
        end

        if params[:office_id].present? && params[:office_id] != 'all'
          events = events.where('office_id = ?', params[:office_id])
        end

        if params[:operator_id].present? && params[:operator_id] != 'all'
          # events = events.where(operator_id: params[:operator_id])
          events = events.where('operator_id = ?', params[:operator_id])
        end

        if params[:routetrain_id].present? && params[:routetrain_id] != 'all'
          # events = events.where(routetrain_id: params[:routetrain_id])
          events = events.where('routetrain_id = ?', params[:routetrain_id])
        end

        if events.present?
          events.each do |event|
            route = event.route
            price_per = route.price_per.to_i rescue 0
            price_per_type = route.price_per_type rescue 'KG'
            route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
            quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

            supir = route_allowance.driver_trip.to_i rescue 0
            kernet = route_allowance.helper_trip.to_i rescue 0
            premi = route.bonus.to_i rescue 0
            solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
            tambahan = route_allowance.misc_allowance.to_i rescue 0
            tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
            invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

            quantity = event.qty.to_i rescue 0
            event_price_per_type = event.price_per_type rescue 'KG'
            event_tonage = event.estimated_tonage.to_i rescue 0

            if contract_used.include? contract.id
              estimation = 0
            else
              estimation = contract.total.to_i rescue 0
              contract_used.push(contract.id)
            end

            ppn = 0
            if event.customer.gst_percentage > 0
              ppn = estimation * event.customer.gst_percentage.to_i / 100
            end
            
            realization = 0
            invoices = Invoice.active.where('event_id = ? AND invoice_id is null AND id not in(select invoice_id from invoicereturns where deleted = false)', event.id).map do |bkk|
    
              bkk_route = bkk.route
              bkk_price_per = bkk_route.price_per.to_i rescue 0
              est_bkk = 0
    
              offset_bkk = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
              if bkk_price_per >= offset_bkk
                est_bkk = bkk_price_per
              else
                est_bkk = bkk.event.estimated_tonage.to_i * bkk_price_per
              end
    
              realization += est_bkk
    
            end

            global_contract_supir += supir
            global_contract_kernet += kernet
            global_contract_solar += solar
            global_contract_tambahan += tambahan
            global_contract_tol_asdp += tol_asdp
            global_contract_premi += premi
            global_contract_invoice_total += invoice_total
            global_contract_ppn_total += ppn
            global_contract_total_estimation += estimation
            global_contract_total_real += realization

            description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>"
            description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"

            @contract_events.push({
              route_name: (route.name rescue "Kosong"),
              route_price: (route.price_per rescue "Kosong"),
              route_id: event.route_id,
              tanktype: event.tanktype,
              office: (event.office.abbr rescue "Kosong"),
              supir: supir,
              username: event.user.username,
              kernet: kernet,
              solar: solar,
              ppn: ppn,
              tambahan: tambahan,
              premi_allowance: premi,
              tol_asdp: tol_asdp,
              invoice_total: invoice_total,
              total_estimation: estimation,
              description: description.html_safe,
              start_date: event.start_date,
              created_at: event.created_at,
              route_train: (event.routetrain.name rescue "Kosong"),
              route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
              route_train_id: event.routetrain_id,
              realization: realization
            })
          end
        end
      end

      # @contract_events = @eventsa.where(id: exevents).map do |event|
      #   route = event.route
      #   price_per = route.price_per.to_i rescue 0
      #   price_per_type = route.price_per_type rescue 'KG'
      #   route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
      #   quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

      #   supir = route_allowance.driver_trip.to_i rescue 0
      #   kernet = route_allowance.helper_trip.to_i rescue 0
      #   premi = route.bonus.to_i rescue 0
      #   solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
      #   tambahan = route_allowance.misc_allowance.to_i rescue 0
      #   tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
      #   invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

      #   quantity = event.qty.to_i rescue 0
      #   event_price_per_type = event.price_per_type rescue 'KG'
      #   event_tonage = event.estimated_tonage.to_i rescue 0

      #   if contract_customers.include? event.customer_id
      #     estimation = 0
      #   else
      #     contract = contracts.where(customer_id: event.customer_id).first
      #     estimation = contract.total.to_i rescue 0
      #     contract_customers.push(event.customer_id)
      #   end

      #   global_contract_supir += supir
      #   global_contract_kernet += kernet
      #   global_contract_solar += solar
      #   global_contract_tambahan += tambahan
      #   global_contract_tol_asdp += tol_asdp
      #   global_contract_premi += premi
      #   global_contract_invoice_total += invoice_total
      #   global_contract_total_estimation += estimation


      #   description = "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
      #   {
      #     route_name: (route.name rescue "Kosong"),
      #     route_price: (route.price_per rescue "Kosong"),
      #     route_id: event.route_id,
      #     tanktype: event.tanktype,
      #     office: (event.office.abbr rescue "Kosong"),
      #     supir: supir,
      #     kernet: kernet,
      #     solar: solar,
      #     tambahan: tambahan,
      #     premi_allowance: premi,
      #     tol_asdp: tol_asdp,
      #     invoice_total: invoice_total,
      #     total_estimation: estimation,
      #     description: description,
      #     start_date: event.start_date,
      #     route_train: (event.routetrain.name rescue "Kosong"),
      #     route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
      #     route_train_id: event.routetrain_id
      #   }
      # end

      # render json: @contract_events

      @contract_summary = {
        global_supir: global_contract_supir ,
        global_kernet: global_contract_kernet ,
        global_solar: global_contract_solar ,
        global_tambahan: global_contract_tambahan ,
        global_tol_asdp: global_contract_tol_asdp ,
        global_premi: global_contract_premi ,
        global_invoice_total: global_contract_invoice_total ,
        global_ppn_total: global_contract_ppn_total ,
        global_total_estimation: global_contract_total_estimation ,
        global_total_real: global_contract_total_real ,
      }

      # Grandtotal
      @grandtotal_supir = global_supir + global_contract_supir
      @grandtotal_kernet = global_kernet + global_contract_kernet
      @grandtotal_solar = global_solar + global_contract_solar
      @grandtotal_tambahan = global_tambahan + global_contract_tambahan
      @grandtotal_tol_asdp = global_tol_asdp + global_contract_tol_asdp
      @grandtotal_premi = global_premi + global_contract_premi
      @grandtotal_invoice_total = global_invoice_total + global_contract_invoice_total
      @grandtotal_ppn_total = global_ppn_total + global_contract_ppn_total 
      @grandtotal_total_estimation = global_total_estimation + global_contract_total_estimation
      @grandtotal_total_real = global_total_real + global_contract_total_real

      @section = "estimationreport"
      @where = "estimation_event_expense_cancelled"
    else
      redirect_to root_path()
    end

  end

  def branches
    @pagetitle = 'Laporan Cabang'
    role = cek_roles 'Admin Keuangan, Estimasi'
    if role
      offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      # render json: exevents
      # return false

      @customer_id = params[:customer_id]
      @commodity_id = params[:commodity_id]

      @customers = Customer.where('id in (select customer_id from events where deleted = false and start_date between ? and ?)', @startdate.to_date, @enddate.to_date).order(:name)

      @eventsa = Event.active.where("start_date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date).order(:start_date)

      @transporttype = params[:transporttype]
      @tanktype = params[:tanktype]

      @createdat = params[:createdat]

      if @createdat.present? and @createdat != 'all'
        if @createdat == "08.00-12.00"
          # Filtering records between 08:00 - 12:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 0, 12)
          @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
        else
          # Filtering records between 12:00 - 17:00
          @eventsa = @eventsa.where("EXTRACT(HOUR FROM events.created_at + INTERVAL '7 hours') BETWEEN ? AND ?", 12, 23)
          @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
        end
      end

      if @customer_id.present? and @customer_id != 'all'
        @eventsa = @eventsa.where('customer_id = ?', @customer_id)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @commodity_id.present? and @commodity_id != 'all'
        @eventsa = @eventsa.where('commodity_id = ?', @commodity_id)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if @transporttype.present? and @transporttype != 'all'
        if @transporttype == 'RORO'
          @eventsa = @eventsa.where('invoiceship = true')
        elsif @transporttype == 'LOSING'
          @eventsa = @eventsa.where('losing = true')
        else
          if @transporttype == 'KERETA'
            @eventsa = @eventsa.where('invoicetrain = true')
          else
            @eventsa = @eventsa.where('invoicetrain = false')
          end
        end
      end

      if @tanktype.present? and @tanktype != 'all'
        @eventsa = @eventsa.where('tanktype = ?', @tanktype)
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:office_id].present? && params[:office_id] != 'all'
        @eventsa = @eventsa.where(office_id: params[:office_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:operator_id].present? && params[:operator_id] != 'all'
        @eventsa = @eventsa.where(operator_id: params[:operator_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      if params[:routetrain_id].present? && params[:routetrain_id] != 'all'
        @eventsa = @eventsa.where(routetrain_id: params[:routetrain_id])
        @customers = @customers.where('id in (select customer_id from events where id in (?))', @eventsa.pluck(:id)).order(:name)
      end

      global_supir = 0
      global_kernet = 0
      global_solar = 0
      global_tambahan = 0
      global_tol_asdp = 0
      global_premi = 0
      global_invoice_total = 0
      global_total_estimation = 0
      solar_price = Setting.find_by_name("Harga Solar").value.to_i
      customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)

      @events = @eventsa.map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0

        # if price_per >= offset
        #   estimation = quantity * price_per
        # elsif customer_35.include? event.customer_id
        #   estimation = quantity * 20000 * price_per
        # elsif(price_per_type == 'KG') #Utk BKK yg masuk di input di BKK kereta tonage   dibuat 20,000 kg
        #   estimation = quantity * event_tonage * price_per
        # else
        #   estimation = quantity * event_tonage * price_per
        # end

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        global_supir += supir
        global_kernet += kernet
        global_solar += solar
        global_tambahan += tambahan
        global_tol_asdp += tol_asdp
        global_premi += premi
        global_invoice_total += invoice_total
        global_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end
      
      @summary = {
        global_supir: global_supir ,
        global_kernet: global_kernet ,
        global_solar: global_solar ,
        global_tambahan: global_tambahan ,
        global_tol_asdp: global_tol_asdp ,
        global_premi: global_premi ,
        global_invoice_total: global_invoice_total ,
        global_total_estimation: global_total_estimation ,
      }

      #perbranch
      #sda
      sda_supir = 0
      sda_kernet = 0
      sda_solar = 0
      sda_tambahan = 0
      sda_tol_asdp = 0
      sda_premi = 0
      sda_invoice_total = 0
      sda_total_estimation = 0

      @events_sda = @eventsa.includes(:route).where("office_id = 1").map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        sda_supir += supir
        sda_kernet += kernet
        sda_solar += solar
        sda_tambahan += tambahan
        sda_tol_asdp += tol_asdp
        sda_premi += premi
        sda_invoice_total += invoice_total
        sda_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          id: event.id,
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end

      # render json: @events_sda.map { |event| event[:id] }
      @customers_sda = @customers.where('id in (select customer_id from events where id in (?))', @events_sda.map { |event| event[:id] })
      @vehicles_sda = Vehicle.where('office_id = 1 AND id in (select vehicle_id from invoices where deleted = false AND office_id = 1 AND event_id in (?))', @events_sda.map { |event| event[:id] })
      @drivers_sda = Driver.where('id in (select driver_id from invoices where deleted = false AND office_id = 1 AND event_id in (?))', @events_sda.map { |event| event[:id] })
      @ship_sda = @eventsa.where('deleted = false AND losing = false AND invoiceship = true AND id in (?)', @events_sda.map { |event| event[:id] }).count()
      @train_sda = @eventsa.where('deleted = false AND losing = false AND invoicetrain = true AND id in (?)', @events_sda.map { |event| event[:id] }).count()
      @losing_sda = @eventsa.where('deleted = false AND losing = true AND id in (?)', @events_sda.map { |event| event[:id] }).count()
      @industry_sda = @eventsa.where('deleted = false AND losing = false AND invoicetrain = false AND invoiceship = false AND id in (?)', @events_sda.map { |event| event[:id] }).count()
      @invoices = Invoice.where('deleted = false AND kosongan = false AND office_id = 1 AND event_id in (?)', @events_sda.map { |event| event[:id] }).count()
      @kosongans = Invoice.where('deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND office_id = 1', @startdate.to_date, @enddate.to_date).count()
      # render json: @drivers_sda.select(:name).order(:name).count()

      @summary_sda = {
        list_vehicles_sda: @vehicles_sda,
        list_cust_sda: @customers_sda,
        list_driver_sda: @drivers_sda.order(:name),
        count_drivers: @drivers_sda.count(),
        count_vehicles: @vehicles_sda.count(),
        count_train: @train_sda,
        count_roro: @ship_sda,
        count_industry: @industry_sda,
        count_losing: @losing_sda,
        count_customers: @customers_sda.count(),
        count_muat: @invoices,
        count_kosongan: @kosongans,
        global_supir: sda_supir ,
        global_kernet: sda_kernet ,
        global_solar: sda_solar ,
        global_tambahan: sda_tambahan ,
        global_tol_asdp: sda_tol_asdp ,
        global_premi: sda_premi ,
        global_invoice_total: sda_invoice_total ,
        global_total_estimation: sda_total_estimation ,
      }
      #sby
      sby_supir = 0
      sby_kernet = 0
      sby_solar = 0
      sby_tambahan = 0
      sby_tol_asdp = 0
      sby_premi = 0
      sby_invoice_total = 0
      sby_total_estimation = 0
      @events_sby = @eventsa.where("office_id = 5").map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        sby_supir += supir
        sby_kernet += kernet
        sby_solar += solar
        sby_tambahan += tambahan
        sby_tol_asdp += tol_asdp
        sby_premi += premi
        sby_invoice_total += invoice_total
        sby_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          id: event.id,
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end
      # render json: @events_sby.map { |event| event[:id] }
      @customers_sby = @customers.where('id in (select customer_id from events where id in (?))', @events_sby.map { |event| event[:id] })
      @vehicles_sby = Vehicle.where('id in (select vehicle_id from invoices where deleted = false AND office_id = 5 AND event_id in (?))', @events_sby.map { |event| event[:id] })
      @drivers_sby = Driver.where('id in (select driver_id from invoices where deleted = false AND office_id = 5 AND event_id in (?))', @events_sby.map { |event| event[:id] })
      @ship_sby = @eventsa.where('deleted = false AND losing = false AND invoiceship = true AND id in (?)', @events_sby.map { |event| event[:id] }).count()
      @train_sby = @eventsa.where('deleted = false AND losing = false AND invoicetrain = true AND id in (?)', @events_sby.map { |event| event[:id] }).count()
      @losing_sby = @eventsa.where('deleted = false AND losing = true AND id in (?)', @events_sby.map { |event| event[:id] }).count()
      @industry_sby = @eventsa.where('deleted = false AND losing = false AND invoicetrain = false AND invoiceship = false AND id in (?)', @events_sby.map { |event| event[:id] }).count()
      @invoice_sby = Invoice.where('deleted = false AND kosongan = false AND office_id = 5 AND event_id in (?)', @events_sby.map { |event| event[:id] }).count()
      @kosongan_sby = Invoice.where('deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND office_id = 5', @startdate.to_date, @enddate.to_date).count()
      # render json: @kosongans

      @summary_sby = {
        list_vehicles_sby: @vehicles_sby,
        list_cust_sby: @customers_sby,
        list_driver_sby: @drivers_sby.order(:name),
        count_drivers: @drivers_sby.count(),
        count_vehicles: @vehicles_sby.count(),
        count_train: @train_sby,
        count_roro: @ship_sby,
        count_industry: @industry_sby,
        count_losing: @losing_sby,
        count_customers: @customers_sby.count(),
        count_muat: @invoice_sby,
        count_kosongan: @kosongan_sby,
        global_supir: sby_supir ,
        global_kernet: sby_kernet ,
        global_solar: sby_solar ,
        global_tambahan: sby_tambahan ,
        global_tol_asdp: sby_tol_asdp ,
        global_premi: sby_premi ,
        global_invoice_total: sby_invoice_total ,
        global_total_estimation: sby_total_estimation ,
      }
      
      #jkt
      jkt_supir = 0
      jkt_kernet = 0
      jkt_solar = 0
      jkt_tambahan = 0
      jkt_tol_asdp = 0
      jkt_premi = 0
      jkt_invoice_total = 0
      jkt_total_estimation = 0
      @events_jkt = @eventsa.where("office_id = 2").map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        jkt_supir += supir
        jkt_kernet += kernet
        jkt_solar += solar
        jkt_tambahan += tambahan
        jkt_tol_asdp += tol_asdp
        jkt_premi += premi
        jkt_invoice_total += invoice_total
        jkt_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          id: event.id,
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end
      # render json: @events_jkt.map { |event| event[:id] }
      @customers_jkt = @customers.where('id in (select customer_id from events where id in (?))', @events_jkt.map { |event| event[:id] })
      @vehicles_jkt = Vehicle.where('id in (select vehicle_id from invoices where deleted = false AND office_id = 2 AND event_id in (?))', @events_jkt.map { |event| event[:id] })
      @drivers_jkt = Driver.where('id in (select driver_id from invoices where deleted = false AND office_id = 2 AND event_id in (?))', @events_jkt.map { |event| event[:id] })
      @ship_jkt = @eventsa.where('deleted = false AND losing = false AND invoiceship = true AND id in (?)', @events_jkt.map { |event| event[:id] }).count()
      @train_jkt = @eventsa.where('deleted = false AND losing = false AND invoicetrain = true AND id in (?)', @events_jkt.map { |event| event[:id] }).count()
      @losing_jkt = @eventsa.where('deleted = false AND losing = true AND id in (?)', @events_jkt.map { |event| event[:id] }).count()
      @industry_jkt = @eventsa.where('deleted = false AND losing = false AND invoicetrain = false AND invoiceship = false AND id in (?)', @events_jkt.map { |event| event[:id] }).count()
      @invoice_jkt = Invoice.where('deleted = false AND kosongan = false AND office_id = 2 AND event_id in (?)', @events_jkt.map { |event| event[:id] }).count()
      @kosongan_jkt = Invoice.where('deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND office_id = 2', @startdate.to_date, @enddate.to_date).count()
      # render json: @kosongan_jkt

      @summary_jkt = {
        list_vehicles_jkt: @vehicles_jkt,
        list_cust_jkt: @customers_jkt,
        list_driver_jkt: @drivers_jkt.order(:name),
        count_drivers: @drivers_jkt.count(),
        count_vehicles: @vehicles_jkt.count(),
        count_train: @train_jkt,
        count_roro: @ship_jkt,
        count_industry: @industry_jkt,
        count_losing: @losing_jkt,
        count_customers: @customers_jkt.count(),
        count_muat: @invoice_jkt,
        count_kosongan: @kosongan_jkt,
        global_supir: jkt_supir ,
        global_kernet: jkt_kernet ,
        global_solar: jkt_solar ,
        global_tambahan: jkt_tambahan ,
        global_tol_asdp: jkt_tol_asdp ,
        global_premi: jkt_premi ,
        global_invoice_total: jkt_invoice_total ,
        global_total_estimation: jkt_total_estimation ,
      }
      #prb
      prb_supir = 0
      prb_kernet = 0
      prb_solar = 0
      prb_tambahan = 0
      prb_tol_asdp = 0
      prb_premi = 0
      prb_invoice_total = 0
      prb_total_estimation = 0
      @events_prb = @eventsa.where("office_id = 3").map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        prb_supir += supir
        prb_kernet += kernet
        prb_solar += solar
        prb_tambahan += tambahan
        prb_tol_asdp += tol_asdp
        prb_premi += premi
        prb_invoice_total += invoice_total
        prb_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          id: event.id,
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end
      # render json: @events_prb.map { |event| event[:id] }
      @customers_prb = @customers.where('id in (select customer_id from events where id in (?))', @events_prb.map { |event| event[:id] })
      @vehicles_prb = Vehicle.where('id in (select vehicle_id from invoices where deleted = false AND office_id = 3 AND event_id in (?))', @events_prb.map { |event| event[:id] })
      @drivers_prb = Driver.where('id in (select driver_id from invoices where deleted = false AND office_id = 3 AND event_id in (?))', @events_prb.map { |event| event[:id] })
      @ship_prb = @eventsa.where('deleted = false AND losing = false AND invoiceship = true AND id in (?)', @events_prb.map { |event| event[:id] }).count()
      @train_prb = @eventsa.where('deleted = false AND losing = false AND invoicetrain = true AND id in (?)', @events_prb.map { |event| event[:id] }).count()
      @losing_prb = @eventsa.where('deleted = false AND losing = true AND id in (?)', @events_prb.map { |event| event[:id] }).count()
      @industry_prb = @eventsa.where('deleted = false AND losing = false AND invoicetrain = false AND invoiceship = false AND id in (?)', @events_prb.map { |event| event[:id] }).count()
      @invoice_prb = Invoice.where('deleted = false AND kosongan = false AND office_id = 3 AND event_id in (?)', @events_prb.map { |event| event[:id] }).count()
      @kosongan_prb = Invoice.where('deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND office_id = 3', @startdate.to_date, @enddate.to_date).count()
      # render json: @kosongan_prb

      @summary_prb = {
        list_vehicles_prb: @vehicles_prb,
        list_cust_prb: @customers_prb,
        list_driver_prb: @drivers_prb.order(:name),
        count_drivers: @drivers_prb.count(),
        count_vehicles: @vehicles_prb.count(),
        count_train: @train_prb,
        count_roro: @ship_prb,
        count_industry: @industry_prb,
        count_losing: @losing_prb,
        count_customers: @customers_prb.count(),
        count_muat: @invoice_prb,
        count_kosongan: @kosongan_prb,
        global_supir: prb_supir ,
        global_kernet: prb_kernet ,
        global_solar: prb_solar ,
        global_tambahan: prb_tambahan ,
        global_tol_asdp: prb_tol_asdp ,
        global_premi: prb_premi ,
        global_invoice_total: prb_invoice_total ,
        global_total_estimation: prb_total_estimation ,
      }

      #smg
      smg_supir = 0
      smg_kernet = 0
      smg_solar = 0
      smg_tambahan = 0
      smg_tol_asdp = 0
      smg_premi = 0
      smg_invoice_total = 0
      smg_total_estimation = 0
      @events_smg = @eventsa.where("office_id = 4").map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        smg_supir += supir
        smg_kernet += kernet
        smg_solar += solar
        smg_tambahan += tambahan
        smg_tol_asdp += tol_asdp
        smg_premi += premi
        smg_invoice_total += invoice_total
        smg_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          id: event.id,
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end
      # render json: @events_smg.map { |event| event[:id] }
      @customers_smg = @customers.where('id in (select customer_id from events where id in (?))', @events_smg.map { |event| event[:id] })
      @vehicles_smg = Vehicle.where('id in (select vehicle_id from invoices where deleted = false AND office_id = 4 AND event_id in (?))', @events_smg.map { |event| event[:id] })
      @drivers_smg = Driver.where('id in (select driver_id from invoices where deleted = false AND office_id = 4 AND event_id in (?))', @events_smg.map { |event| event[:id] })
      @ship_smg = @eventsa.where('deleted = false AND losing = false AND invoiceship = true AND id in (?)', @events_smg.map { |event| event[:id] }).count()
      @train_smg = @eventsa.where('deleted = false AND losing = false AND invoicetrain = true AND id in (?)', @events_smg.map { |event| event[:id] }).count()
      @losing_smg = @eventsa.where('deleted = false AND losing = true AND id in (?)', @events_smg.map { |event| event[:id] }).count()
      @industry_smg = @eventsa.where('deleted = false AND losing = false AND invoicetrain = false AND invoiceship = false AND id in (?)', @events_smg.map { |event| event[:id] }).count()
      @invoice_smg = Invoice.where('deleted = false AND kosongan = false AND office_id = 4 AND event_id in (?)', @events_smg.map { |event| event[:id] }).count()
      @kosongan_smg = Invoice.where('deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND office_id = 4', @startdate.to_date, @enddate.to_date).count()
      # render json: @train_smg

      @summary_smg = {
        list_vehicles_smg: @vehicles_smg,
        list_cust_smg: @customers_smg,
        list_driver_smg: @drivers_smg.order(:name),
        count_drivers: @drivers_smg.count(),
        count_vehicles: @vehicles_smg.count(),
        count_train: @train_smg,
        count_roro: @ship_smg,
        count_industry: @industry_smg,
        count_losing: @losing_smg,
        count_customers: @customers_smg.count(),
        count_muat: @invoice_smg,
        count_kosongan: @kosongan_smg,
        global_supir: smg_supir ,
        global_kernet: smg_kernet ,
        global_solar: smg_solar ,
        global_tambahan: smg_tambahan ,
        global_tol_asdp: smg_tol_asdp ,
        global_premi: smg_premi ,
        global_invoice_total: smg_invoice_total ,
        global_total_estimation: smg_total_estimation ,
      }

      #smt
      smt_supir = 0
      smt_kernet = 0
      smt_solar = 0
      smt_tambahan = 0
      smt_tol_asdp = 0
      smt_premi = 0
      smt_invoice_total = 0
      smt_total_estimation = 0
      @events_smt = @eventsa.where("office_id = 6").map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end

        smt_supir += supir
        smt_kernet += kernet
        smt_solar += solar
        smt_tambahan += tambahan
        smt_tol_asdp += tol_asdp
        smt_premi += premi
        smt_invoice_total += invoice_total
        smt_total_estimation += estimation

        description = "<strong>#{event.customer.name rescue nil}</strong> - (#{event.commodity.name rescue nil})<br>" 
        description = description +  "#{quantity} Rit ##{event.id}: #{route.name rescue nil}"
        {
          id: event.id,
          route_name: (route.name rescue "Kosong"),
          route_price: (route.price_per rescue "Kosong"),
          route_id: event.route_id,
          tanktype: event.tanktype,
          office: (event.office.abbr rescue "Kosong"),
          supir: supir,
          kernet: kernet,
          solar: solar,
          tambahan: tambahan,
          premi_allowance: premi,
          tol_asdp: tol_asdp,
          invoice_total: invoice_total,
          total_estimation: estimation,
          description: description.html_safe,
          start_date: event.start_date,
          created_at: event.created_at,
          route_train: (event.routetrain.name rescue "Kosong"),
          route_train_container_type: (event.routetrain.container_type rescue "Kosong"),
          route_train_id: event.routetrain_id
        }
      end
      # render json: @events_smt.map { |event| event[:id] }
      @customers_smt = @customers.where('id in (select customer_id from events where id in (?))', @events_smt.map { |event| event[:id] })
      @vehicles_smt = Vehicle.where('id in (select vehicle_id from invoices where deleted = false AND office_id = 6 AND event_id in (?))', @events_smt.map { |event| event[:id] })
      @drivers_smt = Driver.where('id in (select driver_id from invoices where deleted = false AND office_id = 6 AND event_id in (?))', @events_smt.map { |event| event[:id] })
      @ship_smt = @eventsa.where('deleted = false AND losing = false AND invoiceship = true AND id in (?)', @events_smt.map { |event| event[:id] }).count()
      @train_smt = @eventsa.where('deleted = false AND losing = false AND invoicetrain = true AND id in (?)', @events_smt.map { |event| event[:id] }).count()
      @losing_smt = @eventsa.where('deleted = false AND losing = true AND id in (?)', @events_smt.map { |event| event[:id] }).count()
      @industry_smt = @eventsa.where('deleted = false AND losing = false AND invoicetrain = false AND invoiceship = false AND id in (?)', @events_smt.map { |event| event[:id] }).count()
      @invoice_smt = Invoice.where('deleted = false AND kosongan = false AND office_id = 6 AND event_id in (?)', @events_smt.map { |event| event[:id] }).count()
      @kosongan_smt = Invoice.where('deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND office_id = 6', @startdate.to_date, @enddate.to_date).count()
      # render json: @kosongan_smt

      @summary_smt = {
        list_vehicles_smt: @vehicles_smt,
        list_cust_smt: @customers_smt,
        list_driver_smt: @drivers_smt.order(:name),
        count_drivers: @drivers_smt.count(),
        count_vehicles: @vehicles_smt.count(),
        count_train: @train_smt,
        count_roro: @ship_smt,
        count_industry: @industry_smt,
        count_losing: @losing_smt,
        count_customers: @customers_smt.count(),
        count_muat: @invoice_smt,
        count_kosongan: @kosongan_smt,
        global_supir: smt_supir ,
        global_kernet: smt_kernet ,
        global_solar: smt_solar ,
        global_tambahan: smt_tambahan ,
        global_tol_asdp: smt_tol_asdp ,
        global_premi: smt_premi ,
        global_invoice_total: smt_invoice_total ,
        global_total_estimation: smt_total_estimation ,
      }

      # Grandtotal
      @grandtotal_supir = global_supir
      @grandtotal_kernet = global_kernet
      @grandtotal_solar = global_solar
      @grandtotal_tambahan = global_tambahan
      @grandtotal_tol_asdp = global_tol_asdp
      @grandtotal_premi = global_premi
      @grandtotal_invoice_total = global_invoice_total
      @grandtotal_total_estimation = global_total_estimation

      @section = "estimationreport"
      @where = 'branches'
    else
      redirect_to root_path()
    end

  end

  def branches_stats
    @pagetitle = 'Statistik Cabang'
    role = cek_roles 'Admin Keuangan, Estimasi'
    if role

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @events = ['test']

      @summary = {
        count_drivers: 0,
        count_vehicles: 0,
        count_train: 0,
        count_roro: 0,
        count_industry: 0,
        count_losing: 0,
        count_customers: 0,
        count_muat: 0,
        count_kosongan: 0,
        count_incident: 0
      }

      @section = "estimationreport"
      @where = 'branches-stats'
    else
      redirect_to root_path()
    end
  end

  def apibranchstats

    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

    offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000

    customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)

    events = []
    customers = []
    estimations = []

    @offices = Office.active.order(:id).each_with_index.map do |office, index|

      @events = Event.active.where("start_date BETWEEN ? AND ? AND office_id = ? ", @startdate.to_date, @enddate.to_date, office.id).order(:start_date)
      @customer_count = Customer.active.where("id in (?)", @events.select(:customer_id).pluck(:customer_id))

      total_estimation = 0

      @events = @events.map do |event|
        route = event.route
        price_per = route.price_per.to_i rescue 0
        price_per_type = route.price_per_type rescue 'KG'
        route_allowance = route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
        quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0

        supir = route_allowance.driver_trip.to_i rescue 0
        kernet = route_allowance.helper_trip.to_i rescue 0
        premi = route.bonus.to_i rescue 0
        solar = (route_allowance.gas_trip.to_i * solar_price).to_i rescue 0
        tambahan = route_allowance.misc_allowance.to_i rescue 0
        tol_asdp = route.tol_fee.to_i + route.ferry_fee.to_i rescue 0
        invoice_total = (supir + kernet + premi + solar + tambahan + tol_asdp) * quantity

        quantity = event.qty.to_i rescue 0
        event_price_per_type = event.price_per_type rescue 'KG'
        event_tonage = event.estimated_tonage.to_i rescue 0 

        if price_per >= offset
          estimation = quantity * price_per
        elsif customer_35.include? event.customer_id
          estimation = quantity * 20000 * price_per
        else
          estimation = quantity * event_tonage *  price_per
        end
        
        total_estimation += estimation
      end
   
      events[index] = @events.count()
      customers[index] = @customer_count.count()
      estimations[index] = total_estimation
    end
  
    render :json => { :success => true, :events => events, :customers => customers, :estimations => estimations }
  end

  def apibranchstatsbkk

    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

    bkk = []
    bkkkos = []
    bkknon = []

    @offices = Office.active.order(:id).each_with_index.map do |office, index|

      @events = Event.active.where("start_date BETWEEN ? AND ? AND office_id = ? ", @startdate.to_date, @enddate.to_date, office.id).order(:start_date)

      @bkk= Invoice.where('deleted = false AND kosongan = false AND office_id = ? AND event_id in (?)', office.id, @events.pluck(:id))
      @kosongan = Invoice.where("deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND kosongan_type = 'produktif' AND office_id = ?", @startdate.to_date, @enddate.to_date, office.id)
      @kosongan_non = Invoice.where("deleted = false AND date between ? and ? AND kosongan = true AND kosongan_confirmed = true AND kosongan_type = 'non-produktif' AND office_id = ?", @startdate.to_date, @enddate.to_date, office.id)
    
      bkk[index] = @bkk.count()
      bkkkos[index] = @kosongan.count()
      bkknon[index] = @kosongan_non.count()
    end
  
    render :json => { :success => true, :bkk => bkk, :bkkkos => bkkkos, :bkknon => bkknon }
  end

  def apibranchstatsbkkbreakdown

    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

    bkk = []
    bkkkereta = []
    bkk_roro = []
    bkk_losing = []

    @offices = Office.active.order(:id).each_with_index.map do |office, index|

      @events = Event.active.where("start_date BETWEEN ? AND ? AND office_id = ? ", @startdate.to_date, @enddate.to_date, office.id).order(:start_date)
      @events_roro = @events.where('invoiceship = true')
      @events_losing = @events.where('losing = true')

      @bkk = Invoice.where('invoicetrain = false AND deleted = false AND kosongan = false AND office_id = ? AND event_id in (?)', office.id, @events.pluck(:id))
      @bkkkereta = Invoice.where('invoicetrain = true AND deleted = false AND kosongan = false AND office_id = ? AND event_id in (?)', office.id, @events.pluck(:id))

      @bkk_roro = Invoice.where('deleted = false AND kosongan = false AND office_id = ? AND event_id in (?)', office.id, @events_roro.pluck(:id))
      @bkk_losing = Invoice.where('deleted = false AND kosongan = false AND office_id = ? AND event_id in (?)', office.id, @events_losing.pluck(:id))

      bkk[index] = @bkk.count()
      bkkkereta[index] = @bkkkereta.count()
      bkk_roro[index] = @bkk_roro.count()
      bkk_losing[index] = @bkk_losing.count()
    end
  
    render :json => { :success => true, :bkktruk => bkk, :bkkkereta => bkkkereta, :bkk_roro => bkk_roro, :bkk_losing => bkk_losing }
  end

  def apibranchstatsincidents
    @startdate = params[:startdate]
    @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

    # laka
    incidents = []
    # tilang
    tickets = []

    @offices = Office.active.order(:id).each_with_index.map do |office, index|

      @expenses = Officeexpense.active.where("date BETWEEN ? AND ? AND office_id = ? ", @startdate.to_date, @enddate.to_date, office.id).order(:date)
      @incidents = @expenses.where('officeexpensegroup_id = ?', 110)
      @tickets = @expenses.where('officeexpensegroup_id = ?', 128)

      incidents[index] = @incidents.count()
      tickets[index] = @tickets.count()
    end
  
    render :json => { :success => true, :incidents => incidents, :tickets => tickets, }
  end

  def get_routetrains
    @routes = Routetrain.where("deleted = ? and enabled = ? and operator_id = ?", false, true, params[:operator_id])
    render :json => { :success => true, :html => render_to_string(:partial => "reports/routetrains", :layout => false) }.to_json;
  end

  def memocleanings
    role = cek_roles 'Admin Operasional, Admin Marketing, Marketing, Admin Keuangan'

    if role
      @startdate = params[:startdate]
      @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

      @vendor_id = params[:vendor_id]
      @containertype = params[:containertype]

      @containers = Eventcleaningmemo.where('deleted = false AND date between ? and ?', @startdate.to_date, @enddate.to_date).order(:id)

      if @vendor_id.present?
        @containers = @containers.where('vendor_id = ?', @vendor_id)
      end

      if @containertype.present?
        @containers = @containers.where('container_type = ?', @containertype)
      end

      respond_to :html
    else
      redirect_to root_path()
    end
  end

  def billings_stats
    @pagetitle = 'Statistik Penagihan'

    @default_month = Date.today;
    @month = "%02d" % @default_month.month.to_s
    @year = @default_month.year

    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
 
      @taxinvoices = Taxinvoice.where('customer_id is not null').active
      @this_month_taxinvoices = @taxinvoices.where("to_char(created_at, 'MM-YYYY') = ?", "#{@month}-#{@year}")

      @taxinvoices = @taxinvoices.where("created_at BETWEEN ? AND ?", @startdate.to_date.beginning_of_day, @enddate.to_date.end_of_day).order(:long_id)
 
      @stats_tuti = @taxinvoices.where('user_id = ?', 46)
      @stats_alfi = @taxinvoices.where('user_id = ?', 138)
      @stats_sarah = @taxinvoices.where('user_id = ?', 134)
      @stats_suci = @taxinvoices.where('user_id = ?', 139)

      start_of_month = @default_month.at_beginning_of_month
      end_of_month = @default_month.at_beginning_of_month.next_month - 1.day

      @cashin_current_month =
        Bankexpense.joins(:taxinvoice)
                  .where(creditgroup_id: 607)
                  .where("bankexpenses.date BETWEEN ? AND ?", start_of_month, end_of_month) # Use explicit BETWEEN
                  .sum(:total)

      # get all AR from jan 2022
      today = Date.today
      start_date = Date.new(2022, 1, 1)      
      @taxinvoices = Taxinvoice.where('customer_id is not null').active
      @total_current_ar = @taxinvoices
                          .where('date >= ?', start_date)
                          .where('date <= ?', today)
                          .where(paiddate: nil) # Add this line
                          .sum(:total)
      

      # Cashin per Offices
      @offices_data = Office.active.order(:name).map do |office|

      # 1. omzet_office
      omzet_office = Taxinvoice.where('customer_id IS NOT NULL') # Use IS NOT NULL
                              .active
                              .where(office_id: office.id)
                              .where("created_at BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date)
                              .sum(:total)

      # 2. cashin_office
      cashin_office = Bankexpense.joins(:taxinvoice)
                                .where(deleted: false) # This is fine as is
                                .where(creditgroup_id: 607)
                                .where(taxinvoices: { office_id: office.id })
                                .where("bankexpenses.date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date)
                                .sum(:total)

      # 3. invoice_tagihan_count
      invoice_tagihan_count = Taxinvoice.where('customer_id IS NOT NULL') # Use IS NOT NULL
                                        .active
                                        .where(office_id: office.id)
                                        .where("created_at BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date)
                                        .count

        {
          office: office,
          omzet_office: omzet_office,
          cashin_office: cashin_office,
          invoice_tagihan_count: invoice_tagihan_count
        }
      end

      @section = "taxinvoices"
      @where = 'billings-stats'
    else
      redirect_to root_path()
    end
  end

  def billings_stats_bak
    @pagetitle = 'Statistik Penagihan'

    @default_month = Date.today;
    @month = "%02d" % @default_month.month.to_s
    @year = @default_month.year

    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      @taxinvoices = Taxinvoice.where('customer_id is not null').active
      @this_month_taxinvoices = @taxinvoices.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}").order(:long_id)

      @taxinvoices = @taxinvoices.where("date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date).order(:long_id)
      # 46, 138, 134, 139
      @stats_tuti = @taxinvoices.where('user_id = ?', 46)
      @stats_alfi = @taxinvoices.where('user_id = ?', 138)
      @stats_sarah = @taxinvoices.where('user_id = ?', 134)
      @stats_suci = @taxinvoices.where('user_id = ?', 139)

      @section = "taxinvoices"
      @where = 'billings-stats'
    else
      redirect_to root_path()
    end
  end

  def getomzetbillings
		month_text = []
 
		#penagihan
		user_ids = [46, 138, 134, 139]
		@events_by_user = {}
		
		user_ids.each do |user_id|
		  @omzet_per_month = []
		
		  @months = (0..2).map { |i| Date.today.prev_month(i).beginning_of_month }.reverse
		
		  @months.each do |mo|
			month_text << mo.strftime("%b %Y")
			total_bill = 0
		
			@taxinvoices = Taxinvoice.active
			.where("customer_id is not null AND DATE_TRUNC('month', date) = ?", mo.beginning_of_month)
			@taxinvoices.where(user_id: user_id).includes(:user).map do |taxinvoice|
				total_bill += taxinvoice.total
			end
		
			@omzet_per_month << total_bill.ceil / 1000000
		  end
		
		  @events_by_user["omzet_#{user_id}"] = @omzet_per_month
		end

		# this_months = @events_by_user.map(&:last)
		this_months = @events_by_user.values.map(&:last)
		total = this_months.sum


    @default_month = Date.today;
    @month = "%02d" % @default_month.month.to_s
    @year = @default_month.year
    
    @draft_vs_sent = []
    @this_month_taxinvoices = @taxinvoices.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}").order(:long_id)
    @draft_vs_sent << @this_month_taxinvoices.where('sentdate is null').count
    @draft_vs_sent << @this_month_taxinvoices.where('sentdate is not null').count

		
		render json: { success: true, month_text: month_text, users: @events_by_user, this_month: this_months, total: total, draft_vs_sent: @draft_vs_sent }

	end

  def ar_aging
    @pagetitle = 'Umur Piutang Pelanggan'

    @default_month = Date.today;
    @month = "%02d" % @default_month.month.to_s
    @year = @default_month.year

    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role

      @month = params[:month]
      @month = "01" if @month.nil?
      @month = "%02d" % @month.to_s
      @day = "01"
      @year = params[:year]
      @year = Date.today.year if @year.nil?

      @monthEnd = params[:monthEnd]
      @monthEnd = "%02d" % Date.today.month.to_s if @monthEnd.nil?
      @dayEnd = getlastday (@monthEnd.to_s)
      @yearEnd = params[:yearEnd]
      @yearEnd = Date.today.year if @yearEnd.nil?

      #calculate number of month
      @start_date = Date.new(@year.to_i, @month.to_i, 1)
      @end_date = Date.new(@yearEnd.to_i, @monthEnd.to_i, 1)
      @number_of_months = (@end_date.year * 12 + @end_date.month) - (@start_date.year * 12 + @start_date.month) + 1


      @taxinvoices = Taxinvoice.active.joins(:customer)

      @taxinvoices = @taxinvoices.where("date BETWEEN ? AND ?", "#{@year}-#{@month}-#{@day}-","#{@yearEnd}-#{@monthEnd}-#{@dayEnd}")
      @taxinvoices_unpaid = @taxinvoices.where("paiddate is null")
 
      @customers = Customer.active.where("id in (?)", @taxinvoices.pluck('customer_id')).order(:name)
      # render json: @taxinvoices.to_sql
      # return false

      # @customer = Customer.find() rescue nil

      @customer_id = params[:customer_id]

      if @customer_id.present?
        @taxinvoices = @taxinvoices.where("customer_id = ?", @customer_id)
      end

      #mapping new objects

      @grandtotal_omzet = 0
      @grandtotal_piutang = 0
      @grandtotal_cashin = 0

      @customer_datas = @customers.map do |customer|

        omzet = @taxinvoices.where("customer_id = ?", customer.id).sum(:total)
        piutang = @taxinvoices_unpaid.where("customer_id = ?", customer.id).sum(:total)
        # kontrol = omzet - piutang
        kontrol = omzet * 30 / 100
        
        # if piutang > 0
        #   aging = (piutang / omzet) * 365
        # else
        #   aging = 0
        # end
        
        aging = (piutang / omzet) * 365

        cashin = Bankexpense.joins(:taxinvoice)
                  .where("creditgroup_id = ?", 607)
                  .where("bankexpenses.date BETWEEN ? AND ?", @start_date, @end_date)
                  .where('taxinvoices.customer_id = ?', customer.id)
                  .sum('bankexpenses.total')

        rata2_omzet = omzet / @number_of_months.to_f
        rata2_piutang = piutang / @number_of_months.to_f

        limit_piutang = rata2_piutang / rata2_omzet * cashin

        @grandtotal_omzet += omzet
        @grandtotal_piutang += piutang
        @grandtotal_cashin += cashin

        {
          customer_id: (customer.id rescue nil),
          name: (customer.name rescue nil),
          city: (customer.city.upcase rescue nil),
          total_omzet: (omzet rescue 0),
          total_piutang: (piutang rescue 0),
          kontrol_piutang: (kontrol rescue 0),
          cashin: (cashin rescue 0),
          umur_piutang: (aging.round rescue 0),
          limit_piutang: (limit_piutang rescue 0),
          rata2_omzet: (rata2_omzet rescue 0),
          rata2_piutang: (rata2_piutang rescue 0),
          jumlah_bulan: (@number_of_months rescue 1),
          customer_notes: Customernote.where('customer_id = ?', customer.id).enabled.order("created_at DESC").map do |note|
            {
              id: note.id,
              description: note.description,
              user_id: note.user_id,
              created_at: note.created_at.strftime("%Y-%m-%d %H:%M:%S")
            }
          end

        }
      end
      
      @section = "taxinvoices"
      @where = 'ar_aging'
    else
      redirect_to root_path()
    end
  end

  def ar_aging_offices
    @pagetitle = 'Umur Piutang Pelanggan'

    @default_month = Date.today
    @month = "%02d" % @default_month.month
    @year  = @default_month.year

    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan'
    if role
      # parameter filter
      @month     = (params[:month].present? ? params[:month] : "01").to_s.rjust(2, "0")
      @day       = "01"
      @year      = params[:year].present? ? params[:year] : Date.today.year
      @monthEnd  = (params[:monthEnd].present? ? params[:monthEnd] : Date.today.month).to_s.rjust(2, "0")
      @dayEnd    = getlastday(@monthEnd.to_s)
      @yearEnd   = params[:yearEnd].present? ? params[:yearEnd] : Date.today.year

      # calculate number of month
      @start_date = Date.new(@year.to_i, @month.to_i, 1)
      @end_date   = Date.new(@yearEnd.to_i, @monthEnd.to_i, 1)
      @number_of_months = (@end_date.year * 12 + @end_date.month) - (@start_date.year * 12 + @start_date.month) + 1

      # invoices
      @taxinvoices = Taxinvoice.active.joins(:customer).
        where(:date => "#{@year}-#{@month}-#{@day}".. "#{@yearEnd}-#{@monthEnd}-#{@dayEnd}")
      @taxinvoices_unpaid = @taxinvoices.where(:paiddate => nil)

      # customer filter
      @customer_id = params[:customer_id]
      @taxinvoices = @taxinvoices.where(:customer_id => @customer_id) if @customer_id.present?

      # customers (with preload notes)
      @customers = Customer.active.
        where(:id => @taxinvoices.select(:customer_id)).
        includes(:customernotes).
        order(:name)

      # aggregated values
      omzet_per_customer   = @taxinvoices.group(:customer_id).sum(:total)
      piutang_per_customer = @taxinvoices_unpaid.group(:customer_id).sum(:total)
      # cashin_per_customer  = Bankexpense.joins(:taxinvoice).
      #   where("bankexpense_id IS NOT NULL").
      #   where(:creditgroup_id => 607).
      #   where(:date => @start_date..@end_date).
      #   group("taxinvoices.customer_id").
      #   sum(:total)

      cashin_per_customer = Bankexpense
        .joins(:taxinvoice)
        .where(creditgroup_id: 607)
        .where(bankexpenses: { deleted: false, date: @start_date..@end_date })
        .group("taxinvoices.customer_id")
        .sum("bankexpenses.total")

        # render json: piutang_per_customer
        # return false    
        
        # render json: cashin_per_customer
        # return false    

      # grand totals
      @grandtotal_omzet   = 0
      @grandtotal_piutang = 0
      @grandtotal_cashin  = 0

      # build result
      customer_datas = @customers.map do |customer|
        omzet   = omzet_per_customer[customer.id]   || 0
        piutang = piutang_per_customer[customer.id] || 0
        cashin  = cashin_per_customer[customer.id.to_s]  || 0

        kontrol = omzet * 30 / 100
        aging   = omzet > 0 ? (piutang.to_f / omzet) * 365 : 0

        rata2_omzet   = omzet / @number_of_months.to_f
        rata2_piutang = piutang / @number_of_months.to_f
        limit_piutang = rata2_omzet > 0 ? (rata2_piutang / rata2_omzet * cashin) : 0

        @grandtotal_omzet   += omzet
        @grandtotal_piutang += piutang
        @grandtotal_cashin  += cashin

        {
          :customer_id    => customer.id,
          :office_id      => customer.office_id,
          :name           => customer.name,
          :city           => customer.city ? customer.city.upcase : nil,
          :total_omzet    => omzet,
          :total_piutang  => piutang,
          :kontrol_piutang => kontrol,
          :cashin         => cashin,
          :umur_piutang   => aging.round,
          :limit_piutang  => limit_piutang,
          :rata2_omzet    => rata2_omzet,
          :rata2_piutang  => rata2_piutang,
          :jumlah_bulan   => @number_of_months,
          customer_notes: Customernote.where('customer_id = ?', customer.id).enabled.order("created_at DESC").map do |note|
            {
              id: note.id,
              description: note.description,
              user_id: note.user_id,
              created_at: note.created_at.strftime("%Y-%m-%d %H:%M:%S")
            }
          end
        }
      end

      # Grouping berdasarkan office_id
      @customer_datas = customer_datas.group_by { |c| c[:office_id] }

      @section = "taxinvoices"
      @where   = 'ar_aging'
    else
      redirect_to root_path
    end
  end

  def cashins
    @pagetitle = 'Cash In'

    @default_month = Date.today;
    @month = "%02d" % @default_month.month.to_s
    @year = @default_month.year

    role = cek_roles 'Admin Keuangan, Estimasi, Admin Penagihan, Cash In'
    if role

      @startdate = params[:startdate]
      @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
      @enddate = params[:enddate]
      @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

      #get cash in from bankexpenses
      @cashin_current_month =
        Bankexpense.joins(:taxinvoice)
                  .where(deleted: false)
                  .where(creditgroup_id: 607)
                  .where("bankexpenses.date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date) # Now @start_date/@end_date are Date objects
                  .select("DISTINCT bankexpenses.*")
                  .order("bankexpenses.id")

      # render json: @cashin_current_month
      # return false
      
      # get taxinvoices as cash in
      @taxinvoices = Taxinvoice.where('customer_id is not null').active
      # @taxinvoices = @taxinvoices.where("paiddate BETWEEN ? AND ? and paiddate is not null", @startdate.to_date, @enddate.to_date).order(:date)

      @customers = Customer.active.where("id in (?)", @taxinvoices.pluck('customer_id')).order(:name)

      @customer_id = params[:customer_id]
      if @customer_id.present? && @customer_id != 'all'
        @taxinvoices = @taxinvoices.where("customer_id = ?", @customer_id)
      end

      @office_id = params[:office_id]
      if @office_id.present? && @office_id != 'all'
        @taxinvoices = @taxinvoices.where("office_id = ?", @office_id)
      end

      @user_id = params[:user_id]
      if @user_id.present? && @user_id != 'all'
        @taxinvoices = @taxinvoices.where("user_id = ?", @user_id)
      end

      #filter by fields
      @cashin_current_month = @cashin_current_month.where('taxinvoice_id in (?)', @taxinvoices.pluck(:id))

      # @taxinvoice_numbers_in_b = @cashin_current_month.map(&:taxinvoice).compact.map(&:long_id).uniq
      # @different_taxinvoices = @taxinvoices.reject { |ti| @taxinvoice_numbers_in_b.include?(ti.long_id) }

      @section = "taxinvoices"
      @where = 'cashins'

    else
      redirect_to root_path()
    end

  end

end
