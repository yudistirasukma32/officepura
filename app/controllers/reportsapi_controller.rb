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

	def customer_routes
		customers = Customer.active.order(:id)
		
		new_customers = {}
		@customerlist = customers.map do |customer|
			routes = Route.active.where("customer_id = #{customer.id} AND LOWER(name) NOT LIKE LOWER('%kosongan%')").order(:id)
			arr_routes = []
			new_item = {}
			routes.each do |route|
				new_item = {
					id: route.id,
					name: route.name,
					distance: route.distance,
					price_per_type: route.price_per_type,
					item_type: route.item_type,
					description: route.description,
					customer_id: route.customer_id,
					routegroup_id: route.routegroup_id,
					bonus: route.bonus.to_i,
					tol_fee: route.tol_fee.to_i,
					ferry_fee: route.ferry_fee.to_i,
					price_per: route.price_per.to_i,
					is_train: route.is_train,
					is_sea: route.is_sea,
					is_isotank: route.is_isotank,
					transporttype: route.transporttype,
					pos: route.pos,
					route_id: route.route_id,
					estimated_hour: route.estimated_hour,
					office_id: route.office_id,
					commodity_id: route.commodity_id
				}
				arr_routes.push(new_item)
			end

			{
				id: customer.id,
				name: customer.name,
				address: customer.address,
				city: customer.city,
				contact: customer.contact,
				phone: customer.phone,
				mobile: customer.mobile,
				fax: customer.fax,
				npwp: customer.npwp,
				terms_of_payment: customer.terms_of_payment_in_days,
				description: customer.description,
				wholesale_price: customer.wholesale_price.to_i,
				email: customer.email,
				email_alt: customer.email_alt,
				load_hour: customer.load_hour,
				unload_hour: customer.unload_hour,
				route: arr_routes
			}
		end

		render json: {
			message: 'Success',
			status: 200,
			customer: @customerlist,
		}, status: 200
	end

	def vehicle_details
		@year = params[:year]
		@year = Date.today.year if @year.nil?
		@month = params[:month]
		@month = Date.today.strftime('%m') if @month.nil?

		@vehicles = Vehicle.active.where("platform_type IS NOT NULL AND platform_type <> ''")
		
		@vehicleslist = @vehicles.map do |vehicle|
			description_list = [
				"Surat Jalan Sudah Tertagih",
				"Surat Jalan Belum Tertagih",
				"Surat Jalan Generic Sudah Tertagih",
				"Lain-lain / Koreksi Debit",
				"Uang Makan",
				"Lain-lain",
				"Solar Kontan",
				"Premi"
			]
			group_list = [
				"Pemasukan",
				"Pemasukan",
				"Pemasukan",
				"Pemasukan",
				"Pengeluaran",
				"Pengeluaran",
				"Pengeluaran",
				"Pengeluaran"
			]
			total_list = []

			#SUMMARY
			##RITASE
			receiptscount = Receipt.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").count
			receiptreturnscount = Receiptreturn.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").count
			totalrit = receiptscount.to_i - receiptreturnscount.to_i

			##INCOME
			taxinvoices = Taxinvoiceitem.where("extract(year from date) = #{@year} and extract(month from date) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			taxinvoices_generic = Taxgenericitem.where("extract(year from date) = #{@year} and extract(month from date) = #{@month} and deleted = false and taxinvoice_id IS NOT NULL and vehicle_id = #{vehicle.id}").sum(:total)
			inc_others = Receiptexpense.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and expensetype = 'Debit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			totalincome = taxinvoices.to_i + taxinvoices_generic.to_i + inc_others.to_i

			##EXPENSE
			receipts = Receipt.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total) 
			receiptreturns = Receiptreturn.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			receiptpremis = Receiptpremi.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			receiptexpenses = Receiptexpense.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and expensetype = 'Kredit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total)
			productrequests = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(year from date) = #{@year} and extract(month from date) = #{@month} and deleted = false and vehicle_id = #{vehicle.id})").sum(:total) 
			totaloutcome = receipts.to_i + receiptpremis.to_i + receiptexpenses.to_i + productrequests.to_i - receiptreturns.to_i
			
			ban = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(year from date) = #{@year} and extract(month from date) = #{@month} and deleted = false and vehicle_id = #{vehicle.id} and productgroup_id in (1,8,9,10,11))").sum(:total)

			onderdil = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(year from date) = #{@year} and extract(month from date) = #{@month} and deleted = false and vehicle_id = #{vehicle.id} and productgroup_id in (2,3,4,5,6))").sum(:total)

			totalprofitloss = totalincome.to_i - totaloutcome.to_i

			###DETAILS
			####PEMASUKAN
			totalInvoice = Taxinvoiceitem.where("extract(month from date) = #{@month} and extract(year from date) = #{@year} and deleted = false and taxinvoice_id IS NOT NULL and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total).to_i
			# totalGeneric = Taxgenericitem.where("extract(month from date) = #{@month} and extract(year from date) = #{@year} and deleted = false and taxinvoice_id IS NOT NULL and vehicle_id = #{vehicle.id}").sum(:total)
			# totalSudah = totalInvoice.to_i + totalGeneric.to_i

			totalBelum = Taxinvoiceitem.where("extract(month from date) = #{@month} and extract(year from date) = #{@year} and deleted = false and taxinvoice_id IS NULL and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total).to_i

			totalGeneric = Taxgenericitem.where("extract(month from date) = #{@month} and extract(year from date) = #{@year} and deleted = false and taxinvoice_id IS NOT NULL and vehicle_id = #{vehicle.id}").sum(:total).to_i

			totalLain = Receiptexpense.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and expensetype = 'Debit' and deleted = false and officeexpense_id in (select id from officeexpenses where vehicle_id = #{vehicle.id})").sum(:total).to_i

			####PENGELUARAN
			totalReceiptMakan = Receipt.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum("driver_allowance + helper_allowance") 
			receiptReturnMakan = Receiptreturn.where("extract(year from created_at) = #{@year} and extract(month from created_at) = #{@month} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum("driver_allowance + helper_allowance")
			totalMakan = totalReceiptMakan.to_i - receiptReturnMakan.to_i

			totalReceiptLain = Receipt.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum("misc_allowance + tol_fee + ferry_fee")
			receiptReturnLain = Receiptreturn.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum("misc_allowance + tol_fee + ferry_fee")
			totalExpenseLain = totalReceiptLain.to_i - receiptReturnLain.to_i

			# totalSolar = Receipt.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum("gas_allowance").to_i
			totalReceiptSolar = Receipt.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:gas_allowance)
			receiptReturnSolar = Receiptreturn.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:gas_allowance)
			totalSolar = totalReceiptSolar.to_i - receiptReturnSolar.to_i

			premiold = Receiptpremi.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:total)
			preminew = Receipt.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:premi_allowance)
			receiptreturn = Receiptreturn.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and deleted = false and invoice_id in (SELECT id from invoices where vehicle_id = #{vehicle.id})").sum(:premi_allowance)
			if preminew > premiold
				totalPremi = preminew.to_i - receiptreturn.to_i
			else
				totalPremi = premiold.to_i - receiptreturn.to_i
			end

			total_list.concat([totalInvoice, totalBelum, totalGeneric, totalLain, totalMakan, totalExpenseLain, totalSolar, totalPremi])

			@officeexpensegroups = Officeexpensegroup.order(:name)
			@officeexpensegroups.each do |group|
				totalExpenseGroup = Receiptexpense.where("extract(month from created_at) = #{@month} and extract(year from created_at) = #{@year} and expensetype = 'Kredit' and deleted = false and officeexpense_id in (select id from officeexpenses where officeexpensegroup_id = #{group.id} and vehicle_id = #{vehicle.id})").sum(:total)
				description_list.concat([group.name])
				total_list.concat([totalExpenseGroup.to_i])
				group_list.concat(["Pengeluaran"])
			end

			productGroups = Productgroup.order(:name)
			productGroups.each do |pgroup|
				totalExpenseProduct = Productrequestitem.where("productrequest_id in (select id from productrequests where extract(month from date) = #{@month} and extract(year from date) = #{@year} and deleted = false and vehicle_id = #{vehicle.id} and productgroup_id = #{pgroup.id})").sum(:total)
				description_list.concat(["Inventory: " + pgroup.name])
				total_list.concat([totalExpenseProduct.to_i])
				group_list.concat(["Pengeluaran"])
			end

			arr_details = []
			new_item = {}
			description_list.each_with_index do |desc, i|
				new_item = {
					:group => group_list[i], :description => description_list[i], :total => total_list[i]
				}
				arr_details.push(new_item)
			end

			arrDetails = []
			# arrSummary.concat([vehicle.year_made, totalrit, totalincome, totaloutcome, ban.to_i, onderdil.to_i, totalprofitloss])
			hashSummary = {
				year: vehicle.year_made,
				ritase: totalrit,
				income: totalincome,
				expense: totaloutcome,
				ban: ban.to_i,
				onderdil: onderdil.to_i,
				profit_loss: totalprofitloss,
				details: arr_details
			}

			{
				id: vehicle.id,
				nopol: vehicle.current_id,
				jenis: vehicle.platform_type,
				grup: vehicle.vehiclegroup.name,
				tahun: vehicle.year_made,
				kantor: vehicle.office.name,
				origin: "pura",
				summary: hashSummary
			}
		end
 
		render json: {
			message: 'Success',
			status: 200,
			vehicles: @vehicleslist,
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
