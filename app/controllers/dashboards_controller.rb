 class DashboardsController < ApplicationController
    include ApplicationHelper
    include ActionView::Helpers::NumberHelper
    layout "application", :except => [:getgraphdata, :widget]
    before_filter :authenticate_user!, [:set_section, :widget]
     skip_before_filter :authenticate_user!, :only => :widget

	def set_section
	    @section = "reports"
	    @where = "reports"
	end

	def expenses_monthly
		@month = params[:month]
    	@month = "%02d" % Date.today.month.to_s if @month.nil?
    	@year = params[:year]
    	@year = Date.today.year if @year.nil?

    	@date = Date.new(@year.to_i, @month.to_i, 1)
    	render "expenses-monthly"
	end

	def getgraphdata
		
		@month = params[:month]
    	@month = "%02d" % Date.today.month.to_s if @month.nil?
    	@year = params[:year]
		@year = Date.today.year if @year.nil?

		dateStart = Date.new(@year.to_i, @month.to_i, 1)
		dateEnd = Date.new(@year.to_i, @month.to_i + 1) - 1

		objReturnMain = []
		objReturn = []

		(1..dateEnd.strftime('%d').to_i).each do |i|
			running = 0
			dateloop = Date.new(@year.to_i, @month.to_i, i).strftime('%d-%m-%Y')
			
			receipts = Receipt.where("to_char(created_at, 'DD-MM-YYYY') = ?", dateloop)
			running += receipts.sum(:total).to_i if receipts.any?

			receiptpremis = Receiptpremi.where("to_char(date, 'DD-MM-YYYY') = ?", dateloop)
			running += receiptpremis.sum(:total).to_i if receiptpremis.any?

    		receiptorders = Receiptorder.where("to_char(date, 'DD-MM-YYYY') = ?", dateloop)
    		running += receiptorders.sum(:total).to_i if receiptorders.any?

    		objReturn[i-1] = [i, running]
		end

		objReturnMain[0] = objReturn

		respond_to do |format|
       		format.json { render :json => objReturnMain }
     	end
	end

	def expenses_vehicle
		@year = params[:year]
    	@year = Date.today.year if @year.nil?

    	@vehicles = Vehicle.where(:deleted => false).order(:current_id)
		
		@section = "reports2"
		@where = 'graph-expensesvehicle'
		render "expenses-vehicle"
	end

	def getexpensevehicledata
		@year = params[:year]
    	@year = Date.today.year if @year.nil?

    	@vehicles = Vehicle.where(:deleted => false).order(:current_id)
		objReturn = []
		objReturn2 = []

		@vehicles.each_with_index do |vehicle, i|
			
			receipts = Receipt.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total) 
	      	receiptreturns = Receiptreturn.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
	      	receiptpremis = Receiptpremi.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
	      	receiptexpenses = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Kredit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
	      	productrequests = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(year from date) = #{@year} and deleted = false and vehicle_id = #{vehicle.id})").sum(:total) 

			total = receipts.to_i + receiptpremis.to_i + receiptexpenses.to_i + productrequests.to_i - receiptreturns.to_i
    		objReturn[i] = [total.to_i, vehicle.current_id]
    	end
    		
    	objReturn2[0] = objReturn.sort {|a,b| a[0] <=> b[0]}
		respond_to do |format|
	    	format.json {render :json => objReturn2 }
	    end
	end

	def incomes_vehicle
		@year = params[:year]
    	@year = Date.today.year if @year.nil?

    	@vehicles = Vehicle.where(:deleted => false).order(:current_id)
		
		@section = "reports2"
		@where = 'graph-incomesvehicle'
		render "incomes-vehicle"
	end

	def getincomevehicledata
		@year = params[:year]
    	@year = Date.today.year if @year.nil?

    	@vehicles = Vehicle.where(:deleted => false).order(:current_id)
		objReturn = []
		objReturn2 = []

		@vehicles.each_with_index do |vehicle, i|
			taxinvoices = Taxinvoiceitem.where("extract(year from date) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
  			inc_others = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Debit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)

			total = taxinvoices.to_i + inc_others.to_i
    		objReturn[i] = [total.to_i, vehicle.current_id]
	    end
	    
		objReturn2[0] = objReturn.sort {|a,b| a[0] <=> b[0]}
		
		respond_to do |format|
	    	format.json {render :json => objReturn2 }
	    end
	end

	def dashboard_layout
		# begin
		# 	ActiveRecord::Base.transaction do
		# 		Setting.create({
		# 			name: "Inside Transaction",
		# 			value: "Transaction testing",
		# 			editable: true
		# 		})
		# 		# user = User.new
		# 		# user.save!
		# 		messave = "P"
		# 	  end
		#   rescue ActiveRecord::RecordInvalid => exception
		# 	  message = exception.message # prints error message
		#   end
		@date = Date.today.strftime('%d-%m-%Y')

		# Saldo Kas
		@saldoKas = to_currency(Setting.find_by_name("Saldo Kas Kantor").value.to_i) || 0

		# TEMPORARY HIDE FROM DASHBOARD
		# BKK
		# @invoices = Invoice.active.where("to_char(date, 'MM-YYYY') = to_char(now(), 'MM-YYYY') AND id in (SELECT invoice_id FROM receipts where deleted = false)")

		# offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		# @total = estimation = 0
	    # @invoices.each do |invoice|
	    #   qty = invoice.quantity
	    #   qty -= invoice.receiptreturns.where(:deleted => false).sum(:quantity) if invoice.receiptreturns.where(:deleted => false).any? 
	    #     if (invoice.route.price_per || 0) >= offset 
	    #       estimation = qty * (invoice.route.price_per.to_i || 0)
	    #     else
	    #       estimation = qty * 25000 * (invoice.route.price_per.to_i || 0)
	    #     end
	    #   @total += estimation
	    # end

	    # @invoices = Invoice.active.where("to_char(date, 'MM-YYYY') = to_char(now(), 'MM-YYYY') AND id not in (SELECT invoice_id FROM receipts where deleted = false)")
		# @receipts = Receipt.active.where("to_char(created_at, 'MM-YYYY') = to_char(now(), 'MM-YYYY')")

		# @totalBkk = (@invoices.sum(:quantity)+@receipts.sum(:quantity)).to_f
		# receipt = @receipts.sum(:quantity).to_f

		# if @totalBkk == 0
		# 	@persentaseBkk = 0
		# else
		# 	@persentaseBkk = receipt * 100
		# 	@persentaseBkk /= @totalBkk
		# end
		
		# BKM
		# @invoicereturns = Invoicereturn.active.where("to_char(date, 'MM-YYYY') = to_char(now(), 'MM-YYYY') AND id not in (SELECT id from invoicereturns where id in (SELECT invoicereturn_id FROM receiptreturns where deleted = false))") 
		# @receiptreturns = Receiptreturn.active.where("to_char(created_at, 'MM-YYYY') = to_char(now(), 'MM-YYYY')")

		# @totalBkm = (@invoicereturns.sum(:quantity)+@receiptreturns.sum(:quantity)).to_f
		# receiptreturn = @receiptreturns.sum(:quantity).to_f
		# if @totalBkm == 0
		# 	@persentaseBkm = 0
		# else
		# 	@persentaseBkm = receiptreturn * 100
		# 	@persentaseBkm /= @totalBkm
		# end

		# TEMPORARY HIDE FROM DASHBOARD
		# Surat Jalan
		taxinvoiceitems = Taxinvoiceitem.active.where("date BETWEEN now()-INTERVAL '2 month' AND now()").count(:all)
		# taxgenericitems = Taxgenericitem.active.where("date BETWEEN now()-INTERVAL '2 month' AND now()").count(:all)
		@totalDitagihkan = Taxinvoiceitem.active.where("date BETWEEN now()-INTERVAL '2 month' AND now() AND invoice_id IS NOT NULL").count(:all)
		
		@totalSuratjalan = taxinvoiceitems #+ taxgenericitems
		if @totalSuratjalan == 0
			@persentaseSuratJalan = 0
		else
			@persentaseSuratJalan = @totalDitagihkan.to_f * 100
			@persentaseSuratJalan /= @totalSuratjalan.to_f
		end

		# Invoice
		@totalInvoice = Taxinvoice.active.where("date BETWEEN now()-INTERVAL '2 month' AND now()").count(:all)
		@totalPaidinvoice = Taxinvoice.active.where("date BETWEEN now()-INTERVAL '2 month' AND now() AND paiddate is not null").count(:all)

		totalRupiahInvoice = Taxinvoice.active.where("date BETWEEN now()-INTERVAL '2 month' AND now()").sum(:total)
		totalRupiahPaidInvoice = Taxinvoice.active.where("date BETWEEN now()-INTERVAL '2 month' AND now() AND paiddate is not null").sum(:total)

		if totalRupiahInvoice == 0
			@persentaseInvoice = 0
		else
			@persentaseInvoice = (totalRupiahPaidInvoice.to_f / totalRupiahInvoice.to_f)*100
		end

		# TEMPORARY HIDE FROM DASHBOARD
		# @invoicenotpaids = Taxinvoice.active.where("paiddate IS NULL").limit(100).order('period_end asc')


		# MASTER
		@customer = Customer.active.count(:all)
		@supplier = Supplier.active.count(:all)
		@driver = Driver.active.count(:all)
		@staff = Staff.active.count(:all)
		@product = Product.active.where("stock > 0").count(:all)
		@route = Route.active.count(:all)
		@vehicle = Vehicle.active.count(:all)
		@productsale = Productsale.active.count(:all)
	end

    def widget
        @invoices = Invoice.active.where("to_char(date, 'MM-YYYY') = to_char(now(), 'MM-YYYY') AND id not in (SELECT invoice_id FROM receipts where deleted = false)")
        @receipts = Receipt.active.where("to_char(created_at, 'MM-YYYY') = to_char(now(), 'MM-YYYY')")

        @totalBkk = (@invoices.sum(:quantity)+@receipts.sum(:quantity)).to_i
        @receipt = @receipts.sum(:quantity).to_i

        @driver = Driver.active.count(:all)
        @vehicle = Vehicle.active.count(:all)

        render json: {
            message: 'Success',
            status: 200,
            totalInv: @totalBkk,
            totalReceipt: @receipt,
            totalDriver: @driver,
            totalVehicle: @vehicle
        }, status: 200

    end 



	
end