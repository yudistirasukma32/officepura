class ProductordersController < ApplicationController
	include ApplicationHelper
  	include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  	before_filter :authenticate_user!, :set_section
  	protect_from_forgery :except => [:updateitem]
  	ID_GROUP_STOK = 7
  	ID_GROUP_HUTANGTOKO = 19
  
	def set_section
		@section = "transactions2"
		@where = "productorders"
	end

	def index
		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		@productorders = Productorder.where('date = ?', @date.to_date).order(:id)
		respond_to :html
	end

	def confirmation
		@errors = Hash.new 
		@productorder = Productorder.find(params[:id])
		@productorderitems = Productorderitem.where(:productorder_id => @productorder.id)
		@productrequest_id = @productorder.productrequest_id
	end

	def new
		@errors = Hash.new
		@productorder = Productorder.new
	end

	def edit
		@errors = Hash.new 
		@productorder = Productorder.find(params[:id])
		@productorderitems = Productorderitem.where(:productorder_id => @productorder.id)
		@productrequest_id = @productorder.productrequest_id
	end

	def return
		@errors = Hash.new
		@productorderitemreturn = Productorderitemreturn.new
		@productorderitemreturn.date = Date.today.strftime('%d-%m-%Y')
		@productorder = Productorder.find(params[:id])
		@productorderitems = Productorderitem.where(:productorder_id => @productorder.id)
		@productrequest_id = @productorder.productrequest_id
	end

	def printversion
		
	end

	def create
		@errors = Hash.new
		@productorder = Productorder.new
		
		inputs = params[:productorder]
		@productrequest_id = inputs[:productrequest_id]
		if @productrequest_id.blank?
			@errors["productorder"] = "Permintaan barang harus diisi"
		else
			@productrequest = Productrequest.where(:id => @productrequest_id).first rescue nil
			if @productrequest.nil?
				@errors["productorder"] = "Permintaan barang No. '#{zeropad(inputs[:productrequest_id])}' tidak terdaftar."
			else
				@productorder = Productorder.where(:productrequest_id => @productrequest_id).first
				if @productorder.nil?
					@productorder = Productorder.new
				end
				@productrequestitems = Productrequestitem.where(:productrequest_id => @productrequest_id, :requestorder => true)
			end
		end		

		if @errors.length == 0
			if inputs[:process] == 'create'
				
				total = 0
				@productrequestitems.each do |productrequestitem|
					if productrequestitem.productorderitems.any?
						productrequestitem.productorderitems.each do |productorderitem|
							item_id = productorderitem.id.to_s	
							quantity = BigDecimal.new(inputs["quantity_" + item_id].delete('.').gsub(",","."))
							price = inputs["priceper_" + item_id ].to_i

							total += quantity * price
						end
					end
				end

				if checkavailablebudget(total) or current_user.owner
					total = 0
					@productorder.productrequest_id = inputs[:productrequest_id]
					@productorder.date = inputs [:date]
					@productorder.description = inputs[:description]
					@productorder.user_id = current_user.id
					
					if @productorder.save
						@productrequestitems.each do |productrequestitem|
							if productrequestitem.productorderitems.any?
								productrequestitem.productorderitems.each do |productorderitem|
									item_id = productorderitem.id.to_s

									quantity = BigDecimal.new(inputs["quantity_" + item_id].delete('.').gsub(",","."))
									price = inputs["priceper_" + item_id ].to_i
									
									if quantity > 0 and  price > 0
										productorderitem.productorder_id = @productorder.id									
										productorderitem.quantity = quantity 
										productorderitem.price_per = price
										productorderitem.supplier_id = inputs["supplierid_" + item_id]
										productorderitem.bon = inputs["bon_"+item_id] == 'on' ? true : false
										productorderitem.total = quantity * price

										if productorderitem.save
											updateproductstock productorderitem.quantity, productorderitem.product_id
											checkproductprice productorderitem.product_id, productorderitem.price_per
											total += productorderitem.total
										end
									end
								end
							end
						end
						if @productorder.productorderitems.where(:bon => true).count > 0
							createbankexpenserecord @productorder.id, ID_GROUP_STOK, ID_GROUP_HUTANGTOKO
						end
					end

					@productorder.total = total
					@productorder.save

					redirect_to(confirmation_productorder_url(@productorder.id), :notice => "Data Order Pembelian sukses di simpan")
				else
					render :action => "new", :notice => "Permintaan barang melebihi budget pembelian"
				end
				
			else
				@productrequest_id = inputs[:productrequest_id]
				render :action => "new"
			end
		else
			@productrequest_id = inputs[:productrequest_id]
			render :action => "new"
		end
	end


	def update
		@errors = Hash.new
		inputs = params[:productorder]
		inputs_return = params[:productorderitemreturn]

		@productorder = Productorder.find(params[:id])
		@productorderitems = Productorderitem.where(:productorder_id => @productorder.id)
		@productrequest_id = @productorder.productrequest_id
		@productrequest= Productrequest.find(@productrequest_id) rescue nil		
		@productrequestitems = Productrequestitem.where(:productrequest_id => @productrequest_id, :requestorder => true)
		@productorderitemreturn = Productorderitemreturn.new

	
		if inputs[:process] == 'create'
			total = 0
			@productrequestitems.each do |productrequestitem|
				if productrequestitem.productorderitems.any?
					productrequestitem.productorderitems.each do |productorderitem|
						item_id = productorderitem.id.to_s	
						quantity = BigDecimal.new(inputs["quantity_" + item_id].delete('.').gsub(",","."))
						price = inputs["priceper_" + item_id ].to_i

						total += quantity * price
					end
				end
			end

			if checkavailablebudget(total) or current_user.owner
				@productorder.productrequest_id = inputs[:productrequest_id]
				@productorder.date = inputs [:date]
				@productorder.description = inputs[:description]
				@productorder.user_id = current_user.id
				total = 0
				if @productorder.save
					if @productorder.productorderitems.any?
						@productorder.productorderitems.each do |productorderitem|
							item_id = productorderitem.id.to_s
							quantity = BigDecimal.new(inputs["quantity_" + item_id].delete('.').gsub(",","."))
							price = inputs["priceper_" + item_id ].to_i
							if quantity > 0 and price > 0
								old_quantity = productorderitem.quantity

								productorderitem.productorder_id = @productorder.id
								productorderitem.quantity = quantity
								productorderitem.price_per= price
								productorderitem.supplier_id = inputs["supplierid_" + item_id]
								productorderitem.bon = inputs["bon_"+item_id] == 'on' ? true : false
								productorderitem.total = quantity * price
								
								if productorderitem.save
									updateproductstock (quantity - old_quantity), productorderitem.product_id
									checkproductprice productorderitem.product_id, productorderitem.price_per
									total += productorderitem.total
								end
							end
						end
					end

					if @productorder.productorderitems.where(:bon => true).count > 0
						createbankexpenserecord @productorder.id, ID_GROUP_STOK, ID_GROUP_HUTANGTOKO
					end
				end

				@productorder.total = total
				@productorder.save

				redirect_to(confirmation_productorder_url(@productorder.id), :notice => "Data Order Pembelian sukses di simpan")
			else
				render :action => "edit", :notice => "Permintaan barang melebihi budget pembelian."
			end

		elsif inputs[:process] == 'retur'
			if @productorder.productorderitems.any?
				total = 0
				is_saved = true
				@productorder.productorderitems.each do |productorderitem|
					item_id = productorderitem.id.to_s
					quantity_order = BigDecimal.new(inputs["quantity_" + item_id].delete('.').gsub(",","."))
					quantity_retur = BigDecimal.new(inputs_return["quantity_" + item_id].delete('.').gsub(",","."))
					quantity_stock = productorderitem.product.stock
					price = inputs["priceper_" + item_id ].to_i
					if (quantity_retur > 0) and (quantity_retur <= quantity_order) and (quantity_retur <= quantity_stock)
						@productorderitemreturn.productorder_id = @productorder.id
						@productorderitemreturn.supplier_id = productorderitem.supplier_id
						@productorderitemreturn.product_id = productorderitem.product_id
						@productorderitemreturn.quantity = quantity_retur
						@productorderitemreturn.price_per = price
						@productorderitemreturn.total = quantity_retur * price
						@productorderitemreturn.bon = productorderitem.bon
						@productorderitemreturn.date = inputs_return[:date]
						@productorderitemreturn.description = inputs_return[:description]
						
						productorderitem.quantity = quantity_order - quantity_retur
						productorderitem.total = (quantity_order - quantity_retur) * price
						
						if @productorderitemreturn.save
							productorderitem.save
							updateproductstock (quantity_retur*-1), productorderitem.product_id
							total += productorderitem.total
						end
					else
						is_saved = false
					end
				end
				if is_saved
					if @productorder.productorderitemreturns.where(:bon => true).count > 0
						reversebankexpenserecord @productorder.id, ID_GROUP_HUTANGTOKO, ID_GROUP_STOK
					end

					@productorder.total = total
					@productorder.save

					redirect_to(productorders_url, :notice => "Data Retur Pembelian sukses di simpan")
				else
					redirect_to(productorders_url, :notice => "Gagal menyimpan data, Qty Retur melebihi order atau stok.")
				end
			end
		else
			@productrequest_id = inputs[:productrequest_id]
			render :action => "edit"
		end	
	end

	def destroy
		@productorder = Productorder.find(params[:id])
		
		@productorderitems = Productorderitem.where(:productorder_id => @productorder.id)
		
		if @productorder.receiptorders.where(:deleted => false).any?
			redirect_to(productorders_url, :notice => 'Permintaan barang No. #' + zeropad(@productorder.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
		else
			@productorderitems.each do |productorderitem|
				updateproductstock productorderitem.quantity * -1, productorderitem.product_id
			end
			
			if !@productorder.productrequest_id.nil?
				@productrequest = Productrequest.find(@productorder.productrequest_id)
				if @productrequest
					@productrequest.deleted = true
					@productrequest.save
				end
			end

			@productorder.deleteuser_id = current_user.id
			@productorder.deleted = true
			@productorder.save

			destroybankexpenserecord @productorder.id

			redirect_to(productorders_url)
		end
	end

	def getproductbyid
		product = Product.find(params[:product_id]) 

		render :json => {:success => true, :layout => false,
			:product => product
			}.to_json;
	end

	def add
		@errors = Hash.new
		@productorder = Productorder.new
		@productorder.date = Date.today.strftime('%d-%m-%Y')
	end

	def checkproductprice product_id, price
		product = Product.find(product_id)

		if !product.nil?
			if product.unit_price != price
				productpricelog = Productpricelog.new
				productpricelog.product_id = product.id
				productpricelog.old_price = product.unit_price
				productpricelog.new_price = price
				
				if productpricelog.save
					product.unit_price = price
					product.save
				end
			end
		end
	end

	def updateitem
		@errors = Hash.new
		inputs = params[:productorder]	
		@productorder = Productorder.new
		

		quantity = BigDecimal.new(inputs["quantity"].delete('.').gsub(",","."))
		total = quantity * inputs["price_per"].to_i
		if checkavailablebudget(total) or current_user.owner
			if !inputs["product_id"].nil?
				@productorder.date = inputs [:date]
				@productorder.description = inputs[:description]
				@productorder.total	= total

				if @productorder.save
					productorderitem = Productorderitem.new

					productorderitem.productorder_id = @productorder.id
					productorderitem.product_id = inputs["product_id"]
					productorderitem.quantity = quantity
					productorderitem.price_per= inputs["price_per"].to_i
					productorderitem.supplier_id = inputs["supplier_id"]
					productorderitem.bon = inputs["bon"] == 'on' ? true : false
					productorderitem.total = total
					@productorder.user_id = current_user.id

					if productorderitem.save
						updateproductstock productorderitem.quantity, productorderitem.product_id
						checkproductprice productorderitem.product_id, productorderitem.price_per
					end 

					if @productorder.productorderitems.where(:bon => true).count > 0
						createbankexpenserecord @productorder.id, ID_GROUP_STOK, ID_GROUP_HUTANGTOKO
					end

					redirect_to(confirmation_productorder_url(@productorder.id), :notice => "Data Order Pembelian sukses di simpan")
				end
			else
				redirect_to("/productorders/add", :notice => "Permintaan barang gagal disimpan. Silahkan buat permintaan baru.")
			end 
		else
			redirect_to("/productorders/add", :notice => "Permintaan barang melebihi budget pembelian.")
			#render :action => "add", :notice => "Permintaan barang melebihi budget pembelian."
		end
	end

	def createbankexpenserecord productorder_id, debitgroup_id, creditgroup_id
	    @productorder = Productorder.find(productorder_id) rescue nil
	    if @productorder
	    	totalbon = @productorder.productorderitems.where(:bon => true).sum(:total)
	    	if totalbon > 0 
		        @bankexpense = Bankexpense.where(:productorder_id => productorder_id, :debitgroup_id => debitgroup_id, :creditgroup_id => creditgroup_id, :deleted => false).first rescue nil

		        needupdate = @bankexpense.nil? ? false : true

		        @bankexpense = Bankexpense.new if @bankexpense.nil?
		        
		        @bankexpense.debitgroup_id = debitgroup_id
		        @bankexpense.creditgroup_id = creditgroup_id
		        @bankexpense.productorder_id = productorder_id
		       	@bankexpense.description = "Pembelian Bon. #" + zeropad(@productorder.id)
		        @bankexpense.date = @productorder.date
		        
		        if needupdate
		          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		          if !debit_to.nil?
		            debit_to.total -= @bankexpense.total
		            debit_to.save
		          end

		          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		          if !credit_to.nil?
		            credit_to.total += @bankexpense.total
		            credit_to.save
		          end
		        end

		        @bankexpense.total = totalbon
		        
		        if @bankexpense.save
		          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		          if !debit_to.nil?
		            debit_to.total += @bankexpense.total
		            debit_to.save
		          end

		          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		          if !credit_to.nil?
		            credit_to.total -= @bankexpense.total
		            credit_to.save
		          end
		        end
		    end
	    end
  	end

  	def destroybankexpenserecord productorder_id
  		bankexpenses = Bankexpense.where(:productorder_id => productorder_id, :deleted => false)
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

	def reversebankexpenserecord productorder_id, debitgroup_id, creditgroup_id
	    @productorder = Productorder.find(productorder_id) rescue nil
	    productorderitemreturns = @productorder.productorderitemreturns.where(:bon => true).first
	    if @productorder
	    	totalbon = @productorder.productorderitemreturns.where(:bon => true).sum(:total)
	    	if totalbon > 0
		        @bankexpense = Bankexpense.where(:productorder_id => productorder_id, :debitgroup_id => debitgroup_id, :creditgroup_id => creditgroup_id, :deleted => false).first rescue nil

		        needupdate = @bankexpense.nil? ? false : true

		        @bankexpense = Bankexpense.new if @bankexpense.nil?
		        
		        @bankexpense.debitgroup_id = debitgroup_id
		        @bankexpense.creditgroup_id = creditgroup_id
		        @bankexpense.productorder_id = productorder_id
		       	@bankexpense.description = "Retur Pembelian Bon. #" + zeropad(@productorder.id) + " (Jurnal Balik)"
		        @bankexpense.date = productorderitemreturns.date
		        
		        if needupdate
		          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		          if !debit_to.nil?
		            debit_to.total -= @bankexpense.total
		            debit_to.save
		          end

		          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		          if !credit_to.nil?
		            credit_to.total += @bankexpense.total
		            credit_to.save
		          end
		        end

		        @bankexpense.total = totalbon
		        
		        if @bankexpense.save
		          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
		          if !debit_to.nil?
		            debit_to.total += @bankexpense.total
		            debit_to.save
		          end

		          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
		          if !credit_to.nil?
		            credit_to.total -= @bankexpense.total
		            credit_to.save
		          end
		        end
		    end
	    end
  	end
end
