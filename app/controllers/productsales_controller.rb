 class ProductsalesController < ApplicationController
	include ApplicationHelper
	layout "application"
  	before_filter :authenticate_user!, :set_section, :set_role

  	def set_section
	    @section = "masters"
	    @where = "productsales"
	end

	def set_role
		@user_role = 'Admin Keuangan, Admin Gudang'
	end

  	def index
  		role = cek_roles @user_role
	    if role
			@productsales = Productsale.all(:order=>:name)
		    respond_to :html
	    else
	      redirect_to root_path()
	    end
	    
	end

	def new
	    @productsale = Productsale.new
	    @productsale.unit_price = @productsale.unit_price.to_i
	end

	def edit
	    @productsale = Productsale.find(params[:id])
	    @productsale.unit_price = @productsale.unit_price.to_i
	end

  	def create
	    inputs = params[:productsale]
	    @productsale = Productsale.new(inputs)
	    
	    if @productsale.save
	      redirect_to(edit_productsale_path(@productsale), :notice => 'Data Barang Bekas sukses di tambah.')
	    else
	      to_flash(@productsale)
	      render :action => "new"
	    end
  	end

  	def update
	    inputs = params[:productsale]
	    @productsale = Productsale.find(params[:id])

	    if @productsale.update_attributes(inputs)
	       @productsale.save
	       redirect_to(edit_productsale_path(@productsale), :notice => 'Data Barang Bekas sukses di simpan.')
	    else
	      to_flash(@productsale)
	      render :action => "edit"
	    end
  	end

	def destroy
	    @productsale = Productsale.find(params[:id])
	    @productsale.deleted = true
	    @productsale.save
	    redirect_to(productsales_url)
	end 
end