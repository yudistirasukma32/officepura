class ProductrequestsController < ApplicationController
	include ApplicationHelper
  	include ActionView::Helpers::NumberHelper
	layout "application", :except => [:getproductstocks, :getproductbygroupid]
  	before_filter :authenticate_user!, :set_section
  	ID_GROUP_STOK = 7
  	ID_GROUP_HUTANGTOKO = 19

	def set_section
		@section = "transactions2"
		@where = "productrequests"
	end

	def index
		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		# @productrequests = Productrequest.where('date = ?', @date.to_date).order(:id)
		@productgroup_id = Productgroup.find(params[:productgroup_id]).id rescue nil
		if @productgroup_id.nil?
			@productrequests = Productrequest.where('date = ?', @date.to_date).order(:id)
		else
			@productrequests = Productrequest.where('date = ? AND productgroup_id = ?', @date.to_date, @productgroup_id).order(:id)
		end
		respond_to :html
	end

	def new
		@productrequest = Productrequest.new
		@error = Hash.new 
		@productrequestitems = Productrequestitem.where(:productrequest_id => @productrequest.id)
		@date = Date.today.strftime('%d-%m-%Y')
	end

	def edit
		@error = Hash.new 
		@productrequest = Productrequest.find(params[:id])
		@productrequestitems = Productrequestitem.where(:productrequest_id => @productrequest.id)
	end

	def update
		inputs = params[:productrequest]
		@productrequest = Productrequest.find(params[:id])

		if @productrequest.update_attributes(inputs)
	       @productrequest.save
	       redirect_to(confirmation_productrequest_url(@productrequest.id), :notice => "Data Permintaan Barang sukses di simpan")
	    else
	      to_flash(@productrequest)
	      render :action => "edit"
	    end
	end

	def confirmation
		@error = Hash.new 
		@productrequest = Productrequest.find(params[:id])
		@productrequestitems = Productrequestitem.where(:productrequest_id => @productrequest.id, :requestorder => true) rescue nil if @productrequest
	end

	def create
		inputs = params[:productrequest]

		@productrequest = Productrequest.new
		@productrequest.driver_id = inputs["driver_id"] if !inputs["driver_id"].blank?
		@productrequest.vehicle_id = inputs["vehicle_id"] if !inputs["vehicle_id"].blank?
		@productrequest.date = inputs["date"] 
		@productrequest.description = inputs["description"]
		@productrequest.productgroup_id = inputs["productgroup_id"]
		
		total_order = 0

		tire_budget = Tirebudget.where(:vehicle_id => @productrequest.vehicle_id, :productgroup_id => @productrequest.productgroup_id) rescue nil

		check_tirebudget = false
		@stock_before, @qty_budget = 0, 0
		if !tire_budget.empty?
			@qty_budget = tire_budget.first.budget
			if !@qty_budget.nil? && @qty_budget > 0
				@startdate = @productrequest.date.beginning_of_month
				@enddate = @productrequest.date.end_of_month

				@check_qty = Productrequest.active.where("date BETWEEN :startdate AND :enddate", {:startdate => @startdate, :enddate => @enddate}).where(:vehicle_id => @productrequest.vehicle_id, :productgroup_id => @productrequest.productgroup_id)
												
				if !@check_qty.nil?
					@check_qty.each do |productrequest|
						@stock_before += productrequest.productrequestitems.map(&:quantity).sum
					end
				end

				check_tirebudget = true
			end
		end

		# if @productrequest.save
		# 	(1..10).each do |i|
		# 		index = i.to_s
		# 		if !inputs["productid_" + index].blank?	and inputs["quantity_" + index].to_i > 0			
		# 			stock = BigDecimal.new(inputs["stock_" + index].delete('.').gsub(",","."))
		# 			quantity = BigDecimal.new(inputs["quantity_" + index].delete('.').gsub(",","."))
		# 			product = Product.find(inputs["productid_" + index])

		# 			@productrequestitem = Productrequestitem.new
		# 			@productrequestitem.productrequest_id = @productrequest.id
		# 			@productrequestitem.product_id = inputs["productid_" + index]
		# 			@productrequestitem.quantity = quantity
		# 			@productrequestitem.stockgiven = stock > quantity ? quantity : (stock <= 0 ? 0 : stock)
		# 			@productrequestitem.total = quantity * product.unit_price.to_i if !product.nil?

		# 			if stock < quantity
		# 				@productrequestitem.requestorder = true 
		# 			end

		# 			if @productrequestitem.save
		# 				if stock < quantity
		# 					is_need_productorder = true
		# 					@productorderitem = Productorderitem.new

		# 					req_quantity = stock > 0 ? (stock - quantity).abs : quantity

		# 					@productorderitem.productrequestitem_id = @productrequestitem.id
		# 					@productorderitem.product_id = @productrequestitem.product_id
		# 					@productorderitem.quantity = req_quantity
		# 					@productorderitem.requestquantity = req_quantity
		# 					@productorderitem.price_per = @productrequestitem.product.unit_price.to_i
		# 					subtotal = req_quantity * @productrequestitem.product.unit_price.to_i 
		# 					@productorderitem.total = subtotal
		# 					@productorderitem.bon = false

		# 					total_order += subtotal

		# 					@productorderitem.save
		# 				end

		# 				updateproductstock quantity * -1, inputs["productid_" + index]
		# 			end
					
		# 		end
		# 	end

		# 	createbankexpenserecord @productrequest.id

		# 	is_need_productorder = 0
		# 	is_need_productorder = Productrequestitem.where(:productrequest_id => @productrequest.id,:requestorder => true).count 
			
		# 	if is_need_productorder > 0
		# 		productorder = Productorder.new 
		# 		productorder.productrequest_id = @productrequest.id
		# 		productorder.date = inputs["date"]
		# 		productorder.total = total_order

		# 		if productorder.save
		# 			@productrequest.productrequestitems.each do |productrequestitem|
		# 				productrequestitem.productorderitems.each do |orderitem|
		# 					orderitem.productorder_id = productorder.id 
		# 					orderitem.save
		# 				end
		# 			end	
		# 		end

		# 		redirect_to(confirmation_productrequest_url(@productrequest.id), :notice => "Data Permintaan Barang sukses di simpan")
		# 	else
		# 		redirect_to(edit_productrequest_url(@productrequest.id), :notice => "Data Permintaan Barang sukses di simpan")
		# 	end	
		# else
		# 	to_flash(@productrequest)
  #     		render :action => "new"	
		# end

		# DI HIDE DULU
		# productgroup = Productgroup.find(@productrequest.productgroup_id) rescue nil
		# if productgroup.name == "Ban"
		# 	range_quantity = getrangeqty(inputs["date"],inputs["productgroup_id"], inputs["vehicle_id"])
		# 	total_qty = 0
		# 	(1..10).each do |i|
		# 		index = i.to_s
		# 		if !inputs["productid_" + index].blank?	and inputs["quantity_" + index].to_i > 0			
		# 			stock = BigDecimal.new(inputs["stock_" + index].delete('.').gsub(",","."))
		# 			quantity = BigDecimal.new(inputs["quantity_" + index].delete('.').gsub(",","."))
		# 			product = Product.find(inputs["productid_" + index])

		# 			total_qty +=quantity
		# 		end
		# 	end
			
		# 	if total_qty < range_quantity
		# 		save = true
		# 	else
		# 		save = false
		# 	end
		# end
		# ===============

		if check_tirebudget == false
			@productrequest.save
			(1..10).each do |i|
				index = i.to_s
				if !inputs["productid_" + index].blank?	and inputs["quantity_" + index].to_i > 0			
					stock = BigDecimal.new(inputs["stock_" + index].delete('.').gsub(",","."))
					quantity = BigDecimal.new(inputs["quantity_" + index].delete('.').gsub(",","."))
					product = Product.find(inputs["productid_" + index])

					@productrequestitem = Productrequestitem.new
					@productrequestitem.productrequest_id = @productrequest.id
					@productrequestitem.product_id = inputs["productid_" + index]
					@productrequestitem.quantity = quantity
					@productrequestitem.stockgiven = stock > quantity ? quantity : (stock <= 0 ? 0 : stock)
					@productrequestitem.total = quantity * product.unit_price.to_i if !product.nil?

					if stock < quantity
						@productrequestitem.requestorder = true 
					end

					if @productrequestitem.save
						if stock < quantity
							is_need_productorder = true
							@productorderitem = Productorderitem.new

							req_quantity = stock > 0 ? (stock - quantity).abs : quantity

							@productorderitem.productrequestitem_id = @productrequestitem.id
							@productorderitem.product_id = @productrequestitem.product_id
							@productorderitem.quantity = req_quantity
							@productorderitem.requestquantity = req_quantity
							@productorderitem.price_per = @productrequestitem.product.unit_price.to_i
							subtotal = req_quantity * @productrequestitem.product.unit_price.to_i 
							@productorderitem.total = subtotal
							@productorderitem.bon = false

							total_order += subtotal

							@productorderitem.save
						end

						updateproductstock quantity * -1, inputs["productid_" + index]
					end
					
				end
			end

			createbankexpenserecord @productrequest.id

			is_need_productorder = 0
			is_need_productorder = Productrequestitem.where(:productrequest_id => @productrequest.id,:requestorder => true).count 
			
			if is_need_productorder > 0
				productorder = Productorder.new 
				productorder.productrequest_id = @productrequest.id
				productorder.date = inputs["date"]
				productorder.total = total_order

				if productorder.save
					@productrequest.productrequestitems.each do |productrequestitem|
						productrequestitem.productorderitems.each do |orderitem|
							orderitem.productorder_id = productorder.id 
							orderitem.save
						end
					end	
				end

				redirect_to(confirmation_productrequest_url(@productrequest.id), :notice => "Data Permintaan Barang sukses di simpan")
			else
				redirect_to(edit_productrequest_url(@productrequest.id), :notice => "Data Permintaan Barang sukses di simpan")
			end	
		else
			save = false
			product_failed = ""
			(1..10).each do |i|
				index = i.to_s
				if !inputs["productid_" + index].blank?	and inputs["quantity_" + index].to_i > 0			
					stock = BigDecimal.new(inputs["stock_" + index].delete('.').gsub(",","."))
					quantity = BigDecimal.new(inputs["quantity_" + index].delete('.').gsub(",","."))
					product = Product.find(inputs["productid_" + index])

					@stock_before += quantity

					if @stock_before <= @qty_budget
						save = true
					else
						save = false
						product_failed = product.name
						break
					end
				end
			end

			if save == true
				@productrequest.save
				(1..10).each do |i|
				index = i.to_s
					if !inputs["productid_" + index].blank?	and inputs["quantity_" + index].to_i > 0			
						stock = BigDecimal.new(inputs["stock_" + index].delete('.').gsub(",","."))
						quantity = BigDecimal.new(inputs["quantity_" + index].delete('.').gsub(",","."))
						product = Product.find(inputs["productid_" + index])

						@productrequestitem = Productrequestitem.new
						@productrequestitem.productrequest_id = @productrequest.id
						@productrequestitem.product_id = inputs["productid_" + index]
						@productrequestitem.quantity = quantity
						@productrequestitem.stockgiven = stock > quantity ? quantity : (stock <= 0 ? 0 : stock)
						@productrequestitem.total = quantity * product.unit_price.to_i if !product.nil?

						if stock < quantity
							@productrequestitem.requestorder = true 
						end

						if @productrequestitem.save
							if stock < quantity
								is_need_productorder = true
								@productorderitem = Productorderitem.new

								req_quantity = stock > 0 ? (stock - quantity).abs : quantity

								@productorderitem.productrequestitem_id = @productrequestitem.id
								@productorderitem.product_id = @productrequestitem.product_id
								@productorderitem.quantity = req_quantity
								@productorderitem.requestquantity = req_quantity
								@productorderitem.price_per = @productrequestitem.product.unit_price.to_i
								subtotal = req_quantity * @productrequestitem.product.unit_price.to_i 
								@productorderitem.total = subtotal
								@productorderitem.bon = false

								total_order += subtotal

								@productorderitem.save
							end

							updateproductstock quantity * -1, inputs["productid_" + index]
						end
						
					end
				end
				createbankexpenserecord @productrequest.id
				redirect_to(edit_productrequest_url(@productrequest.id), :notice => "Data Permintaan Barang sukses di simpan")
			else
				redirect_to(new_productrequest_url(), :notice => "Jumlah #{product_failed} tidak boleh melebihi budget ban")
			end
			
		end
	end

	def destroy
		@productrequest = Productrequest.find(params[:id])
		@productorder = @productrequest.productorders.active.first rescue nil
		
		if @productorder
			if @productorder.receiptorders.where(:deleted => false).any?
				redirect_to(productrequests_url, :notice => 'Permintaan barang No. #' + zeropad(@productrequest.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
			else
				@productrequest.productrequestitems.each do |productrequestitem|
					updateproductstock productrequestitem.quantity, productrequestitem.product_id
				end

				if !@productorder.nil? 
					@productorder.deleted = true
					@productorder.save

					destroybankexpenserecord @productorder.id, ID_GROUP_STOK, ID_GROUP_HUTANGTOKO
				end
						
				@productrequest.deleted = true
				if @productrequest.save
					bankexpenses = Bankexpense.where(:productrequest_id => @productrequest.id, :deleted => false)	

					if bankexpenses.any?
			  			bankexpenses.each do |bankexpense|
			  				bankexpense.deleted = true
			  				bankexpense.deleteuser_id = current_user.id
			  				if bankexpense.save
			  					if !bankexpense.creditgroup_id.nil?
							        credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
							        if !credit_to.nil?
							            credit_to.total += bankexpense.total
							            credit_to.save
							        end
							    end
			  				end
			  			end
			  		end

					redirect_to(productrequests_url)
				end
			end
		else
			@productrequest.deleted = true
			if @productrequest.save
				@productrequest.productrequestitems.each do |productrequestitem|
					updateproductstock productrequestitem.quantity, productrequestitem.product_id
				end

				bankexpenses = Bankexpense.where(:productrequest_id => @productrequest.id, :deleted => false)	

				if bankexpenses.any?
		  			bankexpenses.each do |bankexpense|
		  				bankexpense.deleted = true
		  				bankexpense.deleteuser_id = current_user.id
		  				if bankexpense.save
		  					if !bankexpense.creditgroup_id.nil?
						        credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
						        if !credit_to.nil?
						            credit_to.total += bankexpense.total
						            credit_to.save
						        end
						    end
		  				end
		  			end
		  		end

				redirect_to(productrequests_url)
			end
		end
	end

	def getproductstocks
		product = Product.find(params[:product_id]) rescue nil
		quantity = product.stock if !product.nil? 
		
		render :json => {:success => true, :layout => false,
			:quantity => quantity
			}.to_json;
	end

	def getrangeqty date,productgroup_id, vehicle_id
		@enddate = date
		@startdate = Date.parse(date).beginning_of_day.strftime('01-%m-%Y')

		stock_request = Productrequestitem.joins(:productrequest)
			.where("productrequests.date BETWEEN :startdate AND :enddate", {:startdate => @startdate.to_date, :enddate => @enddate.to_date})
			.where("productrequests.productgroup_id IN (#{productgroup_id})").sum(:quantity)
			

		quantity = nil
		productgroup = Productgroup.find(productgroup_id) rescue nil
		if productgroup.name == "Ban"
			vehicle = Vehicle.find(vehicle_id) rescue nil
		end
		quantity = (vehicle.tire_target - stock_request) if !vehicle.nil? 
		
		return quantity
	end

	def getrangetires 
		@daterequest = params[:date]
		# @startdate = Date.parse(params[:date]).beginning_of_day.strftime('01-%m-%Y')

		# stock_request = Productrequestitem.joins(:productrequest)
		# 	.where("productrequests.date BETWEEN :startdate AND :enddate", {:startdate => @startdate.to_date, :enddate => @enddate.to_date})
		# 	.where("productrequests.productgroup_id IN (#{params[:productgroup_id]})").sum(:quantity)
			

		# quantity = nil
		# productgroup = Productgroup.find(params[:productgroup_id]) rescue nil
		# if productgroup.name == "Ban"
		# 	vehicle = Vehicle.find(params[:vehicle_id]) rescue nil
		# end
		# quantity = (vehicle.tire_target - stock_request) if !vehicle.nil? 


		tire_budget = Tirebudget.where(:vehicle_id => params[:vehicle_id], :productgroup_id =>params[:productgroup_id]) rescue nil

		@stock_before, @qty_budget = 0, 0
		if !tire_budget.empty?
			@qty_budget = tire_budget.first.budget
			if !@qty_budget.nil? && @qty_budget > 0
				@startdate = @daterequest.beginning_of_month
				@enddate = @daterequest.end_of_month

				@check_qty = Productrequest.active.where("date BETWEEN :startdate AND :enddate", {:startdate => @startdate, :enddate => @enddate}).where(:vehicle_id => @productrequest.vehicle_id, :productgroup_id => @productrequest.productgroup_id)
												
				if !@check_qty.nil?
					@check_qty.each do |productrequest|
						@stock_before += productrequest.productrequestitems.map(&:quantity).sum
					end
				end
			end
		end

		budget_tire = @qty_budget - @stock_before
		
		# return quantity
		render :json => {:success => true, :layout => false,
			:quantity => budget_tire
			}.to_json;
	end

	def getproductgroupname
		productgroup = Productgroup.find(params[:productgroup_id]) rescue nil

		render :json => {:success => true, :layout => false,
			:groupname => productgroup.name
			}.to_json;

	end

	def getproductbygroupid
		products = Product.where(:productgroup_id => params[:productgroup_id], :deleted => false).order(:name)

		render :json => {:success => true, :layout => false,
			:products => products
			}.to_json;

	end

	def createbankexpenserecord productrequest_id

		productrequest = Productrequest.find(productrequest_id) rescue nil
		if productrequest
			@bankexpense = Bankexpense.where(:productrequest_id => productrequest_id, :deleted => false).first rescue nil
			needupdate = @bankexpense.nil? ? false : true
			@bankexpense = Bankexpense.new if @bankexpense.nil?

			@bankexpense.productrequest_id = productrequest_id
			@bankexpense.date = productrequest.date
			@bankexpense.creditgroup_id = ID_GROUP_STOK

			if needupdate
	          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
	          if !credit_to.nil?
	            credit_to.total += @bankexpense.total
	            credit_to.save
	          end
	        end

			total = 0
			description = ''
			productrequest.productrequestitems.each do |item|
				description += item.stockgiven.to_s + "x " + item.product.name + ", "
				total = item.total
			end
			description = description[0...-2]

			@bankexpense.description = description
			@bankexpense.total = total

			if @bankexpense.save
				credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
				if !credit_to.nil?
					credit_to.total -= @bankexpense.total
					credit_to.save
				end
			end
		end
	end

	def destroybankexpenserecord productorder_id, debitgroup_id, creditgroup_id
  		bankexpenses = Bankexpense.where(:productorder_id => productorder_id, :debitgroup_id => debitgroup_id, :creditgroup_id => creditgroup_id, :deleted => false)
  		if bankexpenses.any?
  			bankexpenses.each do |bankexpense|
  				bankexpense.deleted = true
  				bankexpense.deleteuser_id = current_user.id
  				if bankexpense.save
  					if !bankexpense.debitgroup_id.nil?
	  					debit_to = Bankexpensegroup.find(bankexpense.debitgroup_id) rescue nil
				        if !debit_to.nil?
				            debit_to.total -= bankexpense.total
				            debit_to.save
				        end
				    end

				    if !bankexpense.creditgroup_id.nil?
				        credit_to = Bankexpensegroup.find(bankexpense.creditgroup_id) rescue nil
				        if !credit_to.nil?
				            credit_to.total += bankexpense.total
				            credit_to.save
				        end
				    end
  				end
  			end
  		end
	end
end
