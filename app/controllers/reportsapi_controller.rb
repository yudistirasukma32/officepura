class ReportsapiController < ApplicationController
	
	include ActionView::Helpers::NumberHelper
	
	def annualvehicle
		
		@year = params[:year]
		@year = Date.today.year if @year.nil?

		@vehicles = Vehicle.all(:order=>:current_id)
		
		@date = Date.today.strftime('%d-%m-%Y')

		# Saldo Kas
		@saldoKas = Setting.find_by_name("Saldo Kas Kantor").value.to_i || 0

		# BKK
		@invoices = Invoice.active.where("to_char(date, 'MM-YYYY') = to_char(now(), 'MM-YYYY') AND id in (SELECT invoice_id FROM receipts where deleted = false)")

		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		@total = estimation = 0
	    @invoices.each do |invoice|
	      qty = invoice.quantity
	      qty -= invoice.receiptreturns.where(:deleted => false).sum(:quantity) if invoice.receiptreturns.where(:deleted => false).any? 
	        if (invoice.route.price_per || 0) >= offset 
	          estimation = qty * (invoice.route.price_per.to_i || 0)
	        else
	          estimation = qty * 25000 * (invoice.route.price_per.to_i || 0)
	        end
	      @total += estimation
	    end

	    @invoices = Invoice.active.where("to_char(date, 'MM-YYYY') = to_char(now(), 'MM-YYYY') AND id not in (SELECT invoice_id FROM receipts where deleted = false)")
		@receipts = Receipt.active.where("to_char(created_at, 'MM-YYYY') = to_char(now(), 'MM-YYYY')")
		
		@vehicleCount = Vehicle.active.count(:all)
		
		@totalgroupincome = 0
		@totalgroupoutcome = 0
		
		@vehiclesList = @vehicles.map do |vehicle, i|
			
			totalincome = 0
			totaloutcome = 0
			
			totalincomeQ1 = 0
			totalincomeQ2 = 0
			totalincomeQ3 = 0
			totalincomeQ4 = 0
			
			totaloutcomeQ1 = 0
			totaloutcomeQ2 = 0
			totaloutcomeQ3 = 0
			totaloutcomeQ4 = 0
			
			
			
			#INCOME
			
			taxinvoices = Taxinvoiceitem.where("extract(year from date) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			inc_others = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Debit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)

			totalincome = taxinvoices.to_i + inc_others.to_i
			@totalgroupincome += totalincome
			
			#Q1
			
			taxinvoicesQ1 = Taxinvoiceitem.where("extract(year from date) = #{@year} and extract(quarter from date) = 1 and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			inc_othersQ1 = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Debit' and extract(quarter from created_at) = 1 and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			
			totalincomeQ1 = taxinvoicesQ1.to_i + inc_othersQ1.to_i
			
			#Q2
			
			taxinvoicesQ2 = Taxinvoiceitem.where("extract(year from date) = #{@year} and extract(quarter from date) = 2 and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			inc_othersQ2 = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Debit' and extract(quarter from created_at) = 2 and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			
			totalincomeQ2 = taxinvoicesQ2.to_i + inc_othersQ2.to_i
			
			#Q3
			
			taxinvoicesQ3 = Taxinvoiceitem.where("extract(year from date) = #{@year} and extract(quarter from date) = 3 and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			inc_othersQ3 = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Debit' and extract(quarter from created_at) = 3 and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			
			totalincomeQ3 = taxinvoicesQ3.to_i + inc_othersQ3.to_i
			
			#Q4
			
			taxinvoicesQ4 = Taxinvoiceitem.where("extract(year from date) = #{@year} and extract(quarter from date) = 3 and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			inc_othersQ4 = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Debit' and extract(quarter from created_at) = 3 and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			
			totalincomeQ4 = taxinvoicesQ4.to_i + inc_othersQ4.to_i
			
			
			#EXPENSE
			

			receipts = Receipt.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total) 
			
			receiptreturns = Receiptreturn.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			receiptpremis = Receiptpremi.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			
			receiptexpenses = Receiptexpense.where("extract(year from created_at) = #{@year} and expensetype = 'Kredit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			
			productrequests = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(year from date) = #{@year} and deleted = false and vehicle_id = #{vehicle.id})").sum(:total) 

			gas_allowances = Receipt.where("extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:gas_allowance) 

			totaloutcome = receipts.to_i + receiptpremis.to_i + receiptexpenses.to_i + productrequests.to_i - receiptreturns.to_i
			
			@totalgroupoutcome += totaloutcome

			if totalincome != 0 and totaloutcome != 0   	
				_totalincome = to_currency(totalincome)
				_totaloutcome = to_currency(totaloutcome)
				_totalprofitloss = to_currency(totalincome - totaloutcome)
				{ :id => vehicle.id, :data_origin => 'rdpi', :is_sparepart => false, :current_id => vehicle.current_id, :year => vehicle.year_made, :income_q1 => to_currency(totalincomeQ1), :income_q2 => to_currency(totalincomeQ2), :income_q3 => to_currency(totalincomeQ3), :income_q4 => to_currency(totalincomeQ4), :income => _totalincome, :expense => _totaloutcome, :profit_loss => _totalprofitloss, :receipt_gas_allowances => gas_allowances, :receipt_premis => receiptpremis, :receipt_inventory => productrequests, :receipt_expenses => receiptexpenses }
			else
				{ :id => vehicle.id, :data_origin => 'rdpi', :is_sparepart => false, :current_id => vehicle.current_id, :year => vehicle.year_made, :income_q1 => to_currency(totalincomeQ1), :income_q2 => to_currency(totalincomeQ2), :income_q3 => to_currency(totalincomeQ3), :income_q4 => to_currency(totalincomeQ4), :income => 0, :expense => 0, :profit_loss => 0, :receipt_gas_allowances => gas_allowances, :receipt_premis => receiptpremis, :receipt_inventory => productrequests, :receipt_expenses => receiptexpenses }
			end
			
		end 
		
		@totalPL = @totalgroupincome - @totalgroupoutcome
		
		@summary = { :estimationInvoiceIncome => @total, :cashBalance => @saldoKas, :vehiclesTotal => @vehicleCount, :totalIncome => @totalgroupincome, :totalExpense => @totalgroupoutcome, :totalProfitLoss => @totalPL }

		render json: {
		message: 'Success',
		status: 200,
		lastUpdated: Time.now, 	
		summary: @summary,
		vehicles: @vehiclesList,
		}, status: 200
		
	end

	def get_today_invoice
		today = Date.today
		today = "2021-01-03"
		#   invoice = Invoice.joins(:vehicle).active.where(deleted: false, date: today).select('vehicles.current_id, count(vehicles.current_id)').group("vehicles.current_id")
		#   render json: invoice.pluck("vehicles.current_id")
		invoices = Invoice.joins(:vehicle).joins(:route).joins("join routegroups rg on rg.id = routes.routegroup_id").active.where(deleted: false, date: today).select('vehicles.current_id, routes.name, rg.name as group_name, invoices.description, invoices.quantity, invoices.id, rg.id as group_id')
		
		new_invoices = {}
		invoices.each do |invoice|
			new_invoices[invoice.current_id] = {
				group_id: invoice.group_id,
				group_name: invoice.group_name,
				description: invoice.description,
				quantity: invoice.quantity,
				route_name: invoice.name,
				invoice_id: invoice.id
			}
		end
		render json: {
			vehicle_currentid: invoices.pluck("vehicles.current_id"),
			invoices: new_invoices
		}
	end

end
