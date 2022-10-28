 class ProductsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

  def set_section
    @section = "masters"
    @where = "products"
    @statuses = ["Baru", "Bekas", "Servis"]
  end

  def set_role
    @user_role = 'Admin Gudang, Staf Permintaan Gudang'
  end

  def index
    role = cek_roles @user_role
    if role
      @products = Product.all(:order =>:name)
      respond_to :html
    else
      redirect_to root_path()
    end
    
  end

  def new
		@process = 'new'
    @product = Product.new
    @product.enabled = true
  end

  def edit
		@process = 'edit'
    @product = Product.find(params[:id])
    @product.unit_price = @product.unit_price.to_i
    @product.discount_price = @product.discount_price.to_i
    @productorder = Productorderitem.where(:product_id => params[:id]).order(:created_at).reverse.first
  end

  def create
    inputs = params[:product]
    @product = Product.new(inputs)
    @product.stock = inputs[:stock].delete('.').gsub(",",".")
    
    if @product.save
      redirect_to(edit_product_path(@product), :notice => 'Data Barang sukses di tambah.')
    else
      to_flash(@product)
      render :action => "new"
    end
  end

  def update
    inputs = params[:product]
    @product = Product.find(params[:id])

    if @product.update_attributes(inputs)
      @product.stock = inputs[:stock].delete('.').gsub(",",".")
       @product.save
       redirect_to(edit_product_path(@product), :notice => 'Data Barang sukses di simpan.')
    else
      to_flash(@product)
      render :action => "edit"
    end
  end

  def destroy
    @product = Product.find(params[:id])
    @product.deleted = true
    @product.save
    redirect_to(products_url)
  end  
  
  def enable
    @product = Product.find(params[:id])
    @product.update_attributes(:enabled => true)
    redirect_to(products_url)
  end
  
  def disable
    @product = Product.find(params[:id])
    @product.update_attributes(:enabled => false)
    redirect_to(products_url)
  end
end
