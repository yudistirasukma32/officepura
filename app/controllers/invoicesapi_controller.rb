class InvoicesapiController < ApplicationController
    include ApplicationHelper
    include ActionView::Helpers::NumberHelper
	
	def index

		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		$globalDate = @date

		@invoice_id = params[:invoice_id] || ''

		if !@invoice_id.blank?
			@invoices = Invoice.where("id = ?", @invoice_id).where("driver_id != null OR driver_id != 0")
	
			if @invoices.empty?

				render json: {
				message: 'Not Found',
				status: 404,
				}, status: 404

			else

            @invoicelist = @invoices.map do |u|
                { 
                :id => u.id,
                :do => u.event_id,
                :office => u.office.name,    
                :deleted => u.deleted, 
                :date => u.date, 
                :quantity => u.quantity, 
                :total => u.total, 
                :vehicle => u.vehicle.current_id, 
                :driver_name => u.driver.name, 
                :driver_phone => u.driver.phone, 
                :driver_mobile => u.driver.mobile, 
                :route => u.route.name, 
                :customer_name => u.customer.name,
                :invoicetrain => u.invoicetrain,
                :tanktype => u.tanktype,
                :isotank_number => (u.isotank.isotanknumber rescue nil),
                :container_number => (u.container.containernumber rescue nil)
                }
            end

            render json: {
            message: 'Success',
            status: 200,
            invoices: @invoicelist,
            }, status: 200

			end

		else
            
            is_invoicetrain = params[:invoicetrain]
            is_kosongan = params[:kosongan]
            
			@invoices = Invoice.active.where("date = ?", @date.to_date).where("driver_id != null OR driver_id != 0 AND customer_id not in (50,51,144) AND invoicetrain = false").order(:id)
            
            if is_invoicetrain
                @invoices_train = Invoice.active.where("date = ?", @date.to_date).where("driver_id != null OR driver_id != 0").order(:id)
                @invoices = @invoices_train.where("invoicetrain = true")
            end
            
            if is_kosongan
                @invoices_kosongan = Invoice.active.where("date = ?", @date.to_date).where("driver_id != null OR driver_id != 0").order(:id)
                @invoices = @invoices_kosongan.where("customer_id in (50,51,144)")
            end
            
			if @invoices.empty?

				render json: {
				message: 'Not Found',
				status: 404,
				}, status: 404
	
			else

            @invoicelist = @invoices.map do |u|
                { 
                :id => u.id,
                :do => u.event_id,
                :office => u.office.name,    
                :deleted => u.deleted, 
                :date => u.date, 
                :quantity => u.quantity, 
                :total => u.total, 
                :vehicle => u.vehicle.current_id, 
                :driver_name => u.driver.name, 
                :driver_phone => u.driver.phone, 
                :driver_mobile => u.driver.mobile, 
                :route => u.route.name, 
                :customer_name => u.customer.name,
                :invoicetrain => u.invoicetrain,
                :tanktype => u.tanktype,
                :isotank_number => (u.isotank.isotanknumber rescue nil),
                :container_number => (u.container.containernumber  rescue nil)
                }
            end

            render json: {
            message: 'Success',
            status: 200,
            count: @invoicelist.count,
            invoices: @invoicelist,
            }, status: 200
	
			end

		end

  	end
	
	def confirmed
		
		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		$globalDate = @date

		@invoice_id = params[:invoice_id] || ''
		
		if !@invoice_id.blank?
			@invoices = Invoice.active.where('id= :id and date = :date and deleted = false and id in (select invoice_id from receipts)', {:date => @date.to_date, :id => @invoice_id}).order(:id)
			
           @invoicelist = @invoices.map do |u|
                { 
                :id => u.id,
                :do => u.event_id,
                :office => u.office.name,    
                :deleted => u.deleted, 
                :date => u.date, 
                :quantity => u.quantity, 
                :total => u.total, 
                :vehicle => u.vehicle.current_id, 
                :driver_name => u.driver.name, 
                :driver_phone => u.driver.phone, 
                :driver_mobile => u.driver.mobile, 
                :route => u.route.name, 
                :customer_name => u.customer.name,
                :invoicetrain => u.invoicetrain,
                :tanktype => u.tanktype,
                :isotank_number => (u.isotank.isotanknumber rescue nil),
                :container_number => (u.container.containernumber  rescue nil)
                }
            end

			if @invoices.empty?

				render json: {
				message: 'Not Found',
				status: 404,
				}, status: 404

			else

				render json: {
				message: 'Success',
				status: 200,
                count: @invoicelist.count,
				invoices: @invoicelist,
				}, status: 200

			end
			
		else
			
            @invoices = Invoice.active.where('date = :date and deleted = false and id in (select invoice_id from receipts)', {:date => @date.to_date})
            @invoices = @invoices.where("customer_id not in (50,51,144)")
            @invoices = @invoices.where('invoice_id is null').order(:id)

            @invoicelist = @invoices.map do |u|
                
                sj_all = Taxinvoiceitem.active.where('invoice_id = ?', u.id).count
                sj = Taxinvoiceitem.active.where('invoice_id = ? AND money(total) > money(0)', u.id).count
                
                { 
                :id => u.id,
                :inv_first_id => u.invoice_id,
                :do => u.event_id,
                :office => u.office.name,    
                :deleted => u.deleted, 
                :date => u.date, 
                :quantity => u.quantity, 
                :total => u.total, 
                :vehicle => u.vehicle.current_id, 
                :driver_name => u.driver.name, 
                :driver_phone => u.driver.phone, 
                :driver_mobile => u.driver.mobile, 
                :route => u.route.name, 
                :customer_name => u.customer.name,
                :invoicetrain => u.invoicetrain,
                :tanktype => u.tanktype,
                :isotank_number => (u.isotank.isotanknumber rescue nil),
                :container_number => (u.container.containernumber  rescue nil),
                :sj_done => sj,
                :sj_all => sj_all    
                }
            end

			if @invoices.empty?

				render json: {
				message: 'Not Found',
				status: 404,
				}, status: 404

			else

				render json: {
				message: 'Success',
				status: 200,
                count: @invoicelist.count, 
				invoices: @invoicelist,
				}, status: 200

			end
			
		end
 
	end
	
	def detail
        @invoice = Invoice.find(params[:id])
		
		@invoices = Invoice.where("id = ?", params[:id])
		
		@summary = @invoices.map do |u|
            { 
                :id => u.id, 
                :deleted => u.deleted, 
                :date => u.date, 
                :quantity => u.quantity, 
                :total => u.total, 
                :vehicle => u.vehicle.current_id, 
                :driver_name => u.driver.name, 
                :driver_phone => u.driver.phone, 
                :driver_mobile => u.driver.mobile, 
                :route => u.route.name, 
                :customer_name => u.customer.name,
                :invoicetrain => u.invoicetrain,
                :tanktype => u.tanktype,
                :isotank_number => (u.isotank.isotanknumber rescue nil),
                :container_number => (u.container.containernumber rescue nil)
            }
		end
		
		@type = "Invoice"
		
		@invoiceImg = Attachment.where("imageable_type = ? and imageable_id = ?", @type, @invoice.id)
		
		@invoiceImgs = @invoiceImg.map do |u|
			{ :id => u.id, :imgUrl => u.file.thumb('240x240').url(:suffix => "/#{u.name}") }
		end	
		
		if @invoice.blank?
			render json: {
			message: 'Not Found',
			status: 404,
			}, status: 404
		else
			render json: {
			message: 'Success',
			status: 200,
			invoice: @invoice,
			detail: @summary[0],
			images: @invoiceImgs,	
			}, status: 200
		end
			
	end
	
	def invoiceDriver
		@driver_id = params[:driver_id]
		
		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		$globalDate = @date

		@invoice_id = params[:invoice_id] || ''

		if !@invoice_id.blank?
			@invoices = Invoice.where("driver_id = ? and id = ? and id not in (select invoice_id from receipts)", @driver_id, @invoice_id)
		else
			if !@date.blank?
				@invoices = Invoice.where("driver_id = ? and date = ? and id not in (select invoice_id from receipts)", @driver_id, @date.to_date)
			else
				@invoices = Invoice.where("driver_id = ?", @driver_id).order('date DESC')
			end
		end

		@invoicelist = @invoices.map do |u|
			{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :route => u.route.name, :customer_name => u.customer.name }
		end

		if @invoices.empty?

			render json: {
			message: 'Not Found',
			status: 404,
			}, status: 404

		else

			render json: {
			message: 'Success',
			status: 200,
			invoices: @invoicelist,
			}, status: 200

		end
	end
	
	def invoiceDriverLast30Days
		
		@driver_id = params[:driver_id]
		
		@enddate = Date.today.strftime('%d-%m-%Y')
		@startdate = (Date.today - 30.day).strftime('%d-%m-%Y')
		
		@invoices = Invoice.active.where('driver_id = :driver_id and date BETWEEN :startdate AND :enddate and deleted = false', {:driver_id => @driver_id, :startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id)
		
		@invoicelist = @invoices.map do |u|
		{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :driver_mobile => u.driver.mobile, :route => u.route.name, :customer_name => u.customer.name }
		end
			
		if @invoices.empty?

			render json: {
			message: 'Not Found',
			status: 404,
			}, status: 404

		else

			render json: {
			message: 'Success',
			status: 200,
			invoices: @invoicelist,
			}, status: 200

		end			
						
	end	
	
	def invoiceDriverLimit
		
		@driver_id = params[:driver_id]
		@startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y')
		@enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
		
		@invoices = Invoice.active.where('driver_id = :driver_id and date BETWEEN :startdate AND :enddate and deleted = false', {:driver_id => @driver_id, :startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id)
		
		@invoicelist = @invoices.map do |u|
		{ :id => u.id, :date => u.date, :quantity => u.quantity, :total => u.total, :vehicle => u.vehicle.current_id, :driver_name => u.driver.name, :driver_phone => u.driver.phone, :driver_mobile => u.driver.mobile, :route => u.route.name, :customer_name => u.customer.name }
		end
			
		if @invoices.empty?

			render json: {
			message: 'Not Found',
			status: 404,
			}, status: 404

		else

			render json: {
			message: 'Success',
			status: 200,
			invoices: @invoicelist,
			}, status: 200

		end			
						
	end
	
	def invoiceDriverThisMonth
		@driver_id = params[:driver_id]
		@startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y')
		@enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
		@invoices_estimation = Invoice.active.where('driver_id = :driver_id and date BETWEEN :startdate AND :enddate and deleted = false', {:driver_id => @driver_id, :startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id).sum(:quantity).to_f
		
		@receiptsQty = Receipt.active.where('deleted = false and invoice_id in (select id from invoices where date BETWEEN :startdate AND :enddate and deleted = false and driver_id = :driver_id) ', {:driver_id => @driver_id, :startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id).sum(:quantity).to_f 
		
		if @receiptsQty == 0

			render json: {
			message: 'Not Found',
			status: 404,
			sdate: @startdate,
			edate: @enddate
			}, status: 404

		else

			render json: {
			message: 'Success',
			status: 200,
			sdate: @startdate,
			edate: @enddate,
			qty: @receiptsQty,
			}, status: 200

		end
		
	end
	
	def invoiceDriverLastMonth
		@driver_id = params[:driver_id]
		
		# @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y')
		# @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
		
		@startdate = (Date.today.beginning_of_month - 1.month ).strftime('%d-%m-%Y')
		@enddate = (Date.today.at_beginning_of_month - 1.day).strftime('%d-%m-%Y')
		
		@invoices_estimation = Invoice.active.where('driver_id = :driver_id and date BETWEEN :startdate AND :enddate and deleted = false', {:driver_id => @driver_id, :startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id).sum(:quantity).to_f
		
		@receiptsQty = Receipt.active.where('deleted = false and invoice_id in (select id from invoices where date BETWEEN :startdate AND :enddate and deleted = false and driver_id = :driver_id) ', {:driver_id => @driver_id, :startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id).sum(:quantity).to_f 
		
		if @receiptsQty == 0

			render json: {
			message: 'Not Found',
			status: 404,
			sdate: @startdate,
			edate: @enddate
			}, status: 404

		else

			render json: {
			message: 'Success',
			status: 200,
			sdate: @startdate,
			edate: @enddate,
			qty: @receiptsQty,
			}, status: 200

		end
		
	end
	
	def getRoute
		vars = request.query_parameters
		customerId = vars['customer_id']
    	@routes = Route.where(:customer_id => customerId, :enabled => true, :deleted => false).order(:name)
		# render :json => { :success => true, :html => render_to_string(:partial => "invoices/routes", :layout => false) }.to_json; 
		
		render json: {
		message: 'Success Get Routes',
		routes: @routes,
		status: 200,
		}, status: 200
		
	end
	
	def routeDetail
		@route = Route.find(params[:id])
		render json: {
		message: 'Success Get Route Detail',
		route: @route,
		status: 200,
		}, status: 200
		
	end
	
	def customerDetail
		@customer = Customer.find(params[:id])
		render json: {
		message: 'Success Get Customer Detail',
		customer: @customer,
		status: 200,
		}, status: 200
	end
	
	def getVehicle
			vars = request.query_parameters
			vehicleId = vars['vehicle_id']
			
		@vehicles = Vehicle.where(:vehiclegroup_id => vehicleId, :enabled => true, :deleted => false) rescue nil

			render json: {
			message: 'Success Get Vehicles',
			vehicles: @vehicles,
			status: 200,
			}, status: 200	
			
	end	
	
	def getAllowances
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
	
	def createInvoice
		render json: params
		return false
		inputs = params[:invoice]

		# @invoice = Invoice.new(inputs)
		 
		# slug_currency(inputs)

    	@invoice = Invoice.new(inputs)

      if params[:checked_additionalroute] == '1'
        input_route = params[:route]

        route = Route.new(input_route)
        route.enabled = true
        route.ferry_fee = params[:additional_asdp] || 0
        route.tol_fee = params[:additional_tol] || 0

        route.transaction do
          if route.save
            allowance = Allowance.new
            allowance.route_id = route.id
            allowance.driver_trip = params[:additional_um_supir] || 0
            allowance.helper_trip = params[:additional_um_kernet] || 0
            allowance.misc_allowance = params[:additional_lain2] || 0
            allowance.gas_trip = params[:additional_solar] || 0
            vehicle = Vehicle.find(inputs[:vehicle_id]) rescue nil
            allowance.vehiclegroup_id = vehicle.vehiclegroup_id
            allowance.save
          end
        end
      end

      if params[:checked_additionalroute] == '1'
        @invoice_exist = Invoice.where(:route_id => route.id, :vehicle_id => inputs[:vehicle_id], :date => inputs[:date].to_date, :deleted => false, :invoice_id => nil).first()
      else
        @invoice_exist = Invoice.where(:route_id => inputs[:route_id], :vehicle_id => inputs[:vehicle_id], :date => inputs[:date].to_date, :deleted => false, :invoice_id => nil).first()
      end

      if @invoice_exist.nil?
				
        @invoice.update_attributes(inputs)
      
        quantity = total = 0

        @gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
        @invoice.gas_cost = @gascost

        quantity = inputs[:quantity].to_i if inputs[:quantity]
        @invoice.quantity = quantity

        @vehicle = Vehicle.find(inputs[:vehicle_id]) rescue nil
        @invoice.vehicle_id = @vehicle.id

        vehiclegroup_id = @vehicle.vehiclegroup_id if @vehicle
        @invoice.vehiclegroup_id = vehiclegroup_id

        @invoice.need_helper = inputs[:need_helper] == "Yes" ? true : false

        if params[:checked_additionalroute] == '1'
          @allowances = Allowance.where(:route_id => route.id, :vehiclegroup_id => vehiclegroup_id, :deleted => false).first
        else
          @allowances = Allowance.where(:route_id => inputs[:route_id], :vehiclegroup_id => vehiclegroup_id, :deleted => false).first
        end

        if !@allowances.nil?
          if params[:checked_additionalroute] == '1'
            @route = Route.find(route.id)
            @invoice.route_id = route.id
          else
            @route = Route.find(inputs[:route_id])
          end

          @invoice.driver_allowance = quantity * (@allowances.driver_trip || 0)

          @invoice.helper_allowance = @invoice.need_helper ? quantity * (@allowances.helper_trip || 0) : 0

          @invoice.misc_allowance = quantity * (@allowances.misc_allowance || 0)
          
          @invoice.gas_litre = quantity * (@allowances.gas_trip || 0)
          
          @invoice.gas_allowance = @invoice.gas_litre * (@gascost || 0)

          @invoice.ferry_fee = (@route.ferry_fee || 0)

          @invoice.tol_fee = quantity * (@route.tol_fee || 0)

          @invoice.total = @invoice.gas_allowance + @invoice.driver_allowance + @invoice.misc_allowance + @invoice.helper_allowance + @invoice.ferry_fee + @invoice.tol_fee
        end

        if params[:checked_additionalroute] == '1'
          route = Route.find(route.id) rescue nil
        else
          route = Route.find(@invoice.route_id) rescue nil
        end
				
        @invoice.customer_id = route.customer_id
        @invoice.price_per = @invoice.route.price_per || 0
        @invoice.insurance = inputs[:insurance].to_i || 0
        rate = Setting.find_by_name("Rate Asuransi").value.to_f rescue nil || 0
        @invoice.insurance_rate = rate
        @invoice.user_id = params[:user_id]

        if params[:is_newform] == '1'
          checklog = Checklog.find_by_sql("SELECT * FROM checklogs WHERE vehicle_id=#{@invoice.vehicle_id} AND to_char(date, 'dd-mm-yyyy')='#{@invoice.date.strftime('%d-%m-%Y')}' AND deleted=False ").first
          @invoice.driver_id = checklog.driver_id
        end
        
        @invoice.transaction do
          if @invoice.save
            if params[:is_newform] == '1'
              if !checklog.invoice_id.nil?
                new_checklog = Checklog.new
                new_checklog.date = @invoice.date
                new_checklog.vehicle_id = checklog.vehicle_id
                new_checklog.driver_id = checklog.driver_id
                new_checklog.invoice_id = @invoice.id
                new_checklog.save
              else
                checklog.invoice_id = @invoice.id
                checklog.save
              end
            end
						
						@driverOrder = Driverorder.create(driver_id: @invoice.driver_id , invoice_id: @invoice.id)
						
						if @driverOrder.save
							
							render json: {
							message: 'Pembuatan BKK + Order Driver Sukses dengan id #'+ zeropad(@invoice.id),
							status: 200,
							}, status: 200
							
						else
							
							render json: {
							message: 'Error saat pembuatan Order',
							status: 400,
							}, status: 400
							
						end
						
          else
						
						render json: {
						message: 'Error',
						status: 400,
						}, status: 400

          end
        end
      
			else

			render json: {
			message: 'BKK dengan Jurusan dan Nopol yang sama telah diinput dengan id #' + zeropad(@invoice_exist.id),
			invoice_id: @invoice_exist.id,
			status: 200,
			}, status: 200
				
      end

 
	end
	
	def createInvoiceStep2
		inputs = params[:invoice]
		@invoice = Invoice.find(inputs[:id])
		@invoice.gas_voucher = inputs[:gas_voucher].nil? ? 0 : inputs[:gas_voucher].to_i
		@invoice.gas_leftover = inputs[:gas_leftover].nil? ? 0 : inputs[:gas_leftover].to_i

		gas_litre = inputs[:gas_start].nil? ? 0 : inputs[:gas_start].to_i

		@invoice.total -= @invoice.gas_allowance

		@gascost = Setting.find_by_name("Harga Solar").value.to_i rescue nil || 0
		@invoice.gas_cost = @gascost
		
		@invoice.gas_litre = gas_litre - @invoice.gas_voucher - @invoice.gas_leftover
		@invoice.gas_allowance = @invoice.gas_litre * @gascost
		@invoice.total += @invoice.gas_allowance 

    	if @invoice.save
      
			vehicle = @invoice.vehicle
			vehicle.gas_leftover = (vehicle.gas_leftover || 0) - inputs[:gas_leftover].to_i
			
			if vehicle.save

				render json: {
				message: 'Create Invoice Success',
				status: 200,
				}, status: 200
				
			end

		end
	end
	
	def destroy
			
			@current_user_id = params[:user_id]
			
		@invoice = Invoice.find(params[:id])
		
		if @invoice.receipts.where(:deleted => false).any? or @invoice.receiptreturns.where(:deleted => false).any? or @invoice.receiptpremis.where(:deleted => false).any?
		redirect_to(request.referer, :notice => 'BKK No. #' + zeropad(@invoice.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
		else
		@invoice.invoicereturns.each do |invoicereturn|  
			invoicereturn.deleted = true
			invoicereturn.deleteuser_id = @current_user_id
			invoicereturn.save
		end

		@invoice.taxinvoiceitems.each do |taxinvoiceitem|
			taxinvoiceitem.deleted = true
			taxinvoiceitem.save 
		end

		@invoice.bonusreceipts.each do |bonusreceipt|
			bonusreceipt.deleted = true
			bonusreceipt.deleteuser_id = @current_user_id
			bonusreceipt.save
		end

		checklog_count = Checklog.active.where("invoice_id='#{@invoice.id}' AND to_char(date, 'dd-mm-yyyy')='#{@invoice.date.strftime('%d-%m-%Y')}' ").count()

		if checklog_count > 0
			checklog = Checklog.active.where("invoice_id='#{@invoice.id}' AND to_char(date, 'dd-mm-yyyy')='#{@invoice.date.strftime('%d-%m-%Y')}' ").first
			checklog.invoice_id = nil
			checklog.save
		end 

		@invoice.deleteuser_id = @current_user_id
		@invoice.deleted = true
		@invoice.save
				
				@message = 'Success Delete Invoice'

				render json: {
					message: @message,
					status: 200,
				}, status: 200
				
		end
	end

	def get_today_invoice
			today = Date.today
			# today = "2021-09-03"
		#   invoice = Invoice.joins(:vehicle).active.where(deleted: false, date: today).select('vehicles.current_id, count(vehicles.current_id)').group("vehicles.current_id")
		#   render json: invoice.pluck("vehicles.current_id")
		invoices = Invoice.joins(:vehicle).joins(:route).joins("join routegroups rg on rg.id = routes.routegroup_id").active.where(deleted: false, date: today).select('vehicles.current_id, routes.name, rg.name as group_name, invoices.description, invoices.quantity, invoices.id, rg.id as group_id, routes.id as route_id')
		
		new_invoices = {}
		invoices.each do |invoice|
			locations = Routelocation.where(route_id: invoice.route_id)
			latitude = locations.first.latitude_end rescue nil
			longitude = locations.first.longitude_end rescue nil
			new_invoices[invoice.current_id] = {
				group_id: invoice.group_id,
				group_name: invoice.group_name,
				description: invoice.description,
				quantity: invoice.quantity,
				route_name: invoice.name,
				invoice_id: invoice.id,
				latitude: latitude,
				longitude: longitude,
				origin: "pura",
				url: api_detail_invoice_url(id: invoice.id)
			}
		end

		render json: {
			vehicle_currentid: invoices.pluck("vehicles.current_id"),
			invoices: new_invoices
		}
	end

	def get_detail_invoice
		if params[:id].present?
			invoices = Invoice.joins(:vehicle).joins(:route).joins("join routegroups rg on rg.id = routes.routegroup_id").active.where(id: params[:id]).select('vehicles.current_id, routes.name, rg.name as group_name, invoices.description, invoices.quantity, invoices.id, rg.id as group_id, routes.id as route_id')
			if invoices.present?
				locations = Routelocation.where(route_id: invoices.first.route_id)
				latitude = locations.first.latitude_end rescue nil
				longitude = locations.first.longitude_end rescue nil
				
				render json: {
						group_id: invoices.first.group_id,
						group_name: invoices.first.group_name,
						description: invoices.first.description,
						quantity: invoices.first.quantity,
						route_name: invoices.first.name,
						invoice_id: invoices.first.id,
						latitude: latitude,
						longitude: longitude,
						origin: "pura",
						url: api_detail_invoice_url(id: invoices.first.id)
					}
					return false
			end
			render json: {}
		else
			render json: {}
		end

	end

	# NEW API =================================>
	def get_vehicles_by_office_id
		if params[:office_id] == '3' || params[:office_id] == '5'
			@vehicles = Vehicle.where(:office_id => params[:office_id], :enabled => true, :deleted => false).order('current_id ASC') rescue nil
			render :json => { :success => true, :html => render_to_string(:partial => "invoices/vehicles_new"), :layout => false }.to_json;
		else  
			@vehicles = Vehicle.where('enabled = true AND deleted = false AND office_id NOT IN (3,5)').order('current_id ASC') rescue nil
			render :json => { :success => true, :html => render_to_string(:partial => "invoices/vehicles_new"), :layout => false }.to_json;
		end
	end

	def check_tanktype
		if params[:tanktype] == 'ISOTANK'
			@isotanks = Isotank.active.order(:isotanknumber)
		elsif params[:tanktype] == "KONTAINER"
			@containers = Container.active.order(:containernumber)
		end 

		render json: { success: true, html: render_to_string(partial: "invoices/isotank_container") }
	end

	def get_routes
      
		is_train = params[:train]
		customer_id = params[:customer_id]  
			
		if is_train == "0"
			
			if customer_id == "50" || customer_id == "51" || customer_id == "144"
				@routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).order(:name)
			else
				@routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).where("name !~* '.*depo.*'").order(:name)
			end
			
		else
			
			@routes = Route.where(:customer_id => params[:customer_id], :enabled => true, :deleted => false).where("name ~* '.*depo.*'").order(:name)
			
		end
			
		render :json => { :success => true, :train => is_train, :html => render_to_string(:partial => "invoices/routes", :layout => false) }.to_json; 
	end

	def get_office_tanktype_and_customer
		if params[:kosongan] || params[:kosongan] == true
			customers = Customer.where(:enabled => true, :deleted => false).where("name LIKE '%RDPI%'").order(:name) 
		else
			customers = Customer.where(:enabled => true, :deleted => false).where("name LIKE '%RDPI%' OR id in (SELECT DISTINCT customer_id as id from events WHERE customer_id is not null AND end_date BETWEEN current_date - interval '30' day AND current_date + interval '45' day)").order(:name) 
		end

		render json: {
			customers: customers,
			offices: Office.active.order(:name),
			# tanktypes: ["TANGKI",'ISOTANK','KONTAINER']
			tanktypes: ['ISOTANK', 'LOSBAK', 'DROPSIDE', 'TANGKI BESI', 'TANGKI STAINLESS', 'KONTAINER', 'TRUK BOX']
		}
	end

	def getapi_invoices
		@startdate = params[:startdate]
		@startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
		@enddate = params[:enddate]
		@enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

		if params[:invoice_id].present?
			@invoices = Invoice.where("id = ?", params[:invoice_id])
		else
			@invoices = Invoice.active.where("date BETWEEN ? AND ?", @startdate.to_date, @enddate.to_date).order(:id)
		end

		if @invoices.empty?
			render json: {
			message: 'Not Found',
			status: 404,
			}, status: 404

		else
			@invoicelist = @invoices.map do |u|
				{ 
				:id => u.id,
				:do => u.event_id,
				:office => u.office.name,    
				:deleted => u.deleted, 
				:date => u.date, 
				:quantity => u.quantity,
				:office => u.office.name,
				:total => u.total,
				:user => (u.user.username rescue nil),
				:vehicle => u.vehicle.current_id, 
				:driver_name => u.driver.name, 
				:driver_phone => u.driver.phone, 
				:driver_mobile => u.driver.mobile, 
				:route => u.route.name, 
				:customer_name => u.customer.name,
				:invoicetrain => u.invoicetrain,
				:tanktype => u.tanktype,
				:isotank_number => (u.isotank.isotanknumber rescue nil),
				:isotank_category => (u.isotank.category rescue nil),
				:container_number => (u.container.containernumber  rescue nil),
				:vehicle_duplicate => (u.vehicle_duplicate.current_id rescue nil),
				:by_vendor => u.by_vendor,
				:description => u.description
				}
			end

			render json: {
				message: 'Success',
				status: 200,
				count: @invoicelist.count,
				invoices: @invoicelist,
			}, status: 200
		end
	end
end