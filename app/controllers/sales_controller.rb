class SalesController < ApplicationController
	include ApplicationHelper
  	include ActionView::Helpers::NumberHelper
	layout "application", :except => [:getpriceproductsale]
  	before_filter :authenticate_user!, :set_section
  
	def set_section
		@section = "transactions2"
		@where = "sales"
	end

	def index
		@date = params[:date]
		@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
		@sales = Sale.where('date = ?', @date.to_date).order(:id)
		respond_to :html
	end

	def new
		@errors = Hash.new
		@sale = Sale.new
		@sale.date = Date.today.strftime('%d-%m-%Y') if @sale.date.nil?
	end

	def edit
		@errors = Hash.new 
		@sale = Sale.find(params[:id])
		@saleitems = Saleitem.where(:sale_id => @sale.id)
	end

	def create 
		inputs = params[:sale]
		@sale = Sale.new
		@sale.date = inputs[:date]
		@sale.description = inputs[:description]
		@sale.user_id = current_user.id

		if @sale.save
			(1..10).each do |i|
				if inputs["productsaleid_"+ i.to_s].to_i != 0 and inputs["quantity_"+i.to_s].to_i != 0
					saleitem = Saleitem.new
					saleitem.sale_id = @sale.id
					saleitem.productsale_id = inputs["productsaleid_"+i.to_s].to_i
					saleitem.quantity = inputs["quantity_"+i.to_s].to_i

					productsale = Productsale.find(inputs["productsaleid_"+i.to_s].to_i) rescue nil

					saleitem.price_per = productsale.unit_price
					saleitem.total = saleitem.quantity * saleitem.price_per
					saleitem.save
				end
			end
			@sale.total = @sale.saleitems.sum(:total)
			@sale.save	

			redirect_to(confirmation_sale_url(@sale.id), :notice => "Data Penjualan Barang sukses di simpan")
		else
			to_flash(@sale)
      		render :action => "new"	
		end

	end

	def update
		inputs = params[:sale]
		@sale = Sale.find(params[:id])
		@sale.date = inputs[:date]
		@sale.description = inputs[:description]

		if @sale.save
			@sale.saleitems.each do |saleitem|
				if inputs["quantity_"+saleitem.id.to_s].to_i != 0
					saleitem.quantity = inputs["quantity_"+saleitem.id.to_s].to_i

					saleitem.total = saleitem.quantity * saleitem.price_per
					saleitem.save
				end
			end
			@sale.total = @sale.saleitems.sum(:total)
			@sale.save	

			redirect_to(confirmation_sale_url(@sale.id), :notice => "Data Penjualan Barang sukses di simpan")
		else
			to_flash(@sale)
      		render :action => "new"	
		end
	end

	def confirmation
		@errors = Hash.new 
		@sale = Sale.find(params[:id])
		@saleitems = Saleitem.where(:sale_id => @sale.id)
	end

	def getpriceproductsale
		productsale = Productsale.find(params[:productsale_id]) rescue nil
		puts productsale.unit_price
		price = productsale.unit_price.to_i if !productsale.nil?

		render :json => {:success => true, :layout => false,
			:price => price
			}.to_json;
	end

	def destroy
		@sale = Sale.find(params[:id])
		
		if @sale.receiptsales.where(:deleted => false).any?
			redirect_to(sales_url, :notice => 'Penjualan barang No. #' + zeropad(@sale.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
		else	

			@sale.deleteuser_id = current_user.id
			@sale.deleted = true
			@sale.save	

			redirect_to(sales_url)
		end

	end
end