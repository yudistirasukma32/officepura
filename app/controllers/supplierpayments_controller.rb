class SupplierpaymentsController < ApplicationController
	include ApplicationHelper
  include ActionView::Helpers::NumberHelper
	layout "application", :except => []
  before_filter :authenticate_user!, :set_section

  def set_section
   	@section = "transactions"
    @where = "supplierpayments"
  end

  def index
    @month = params[:month]
    @month = "%02d" % Date.today.month.to_s if @month.nil?
    @year = params[:year]
    @year = Date.today.year if @year.nil?

    @productorderitems = Productorderitem.where("to_char(created_at, 'MM-YYYY') = ? AND bon = ? AND productorder_id <> ?", "#{@month}-#{@year}" ,true, 0)

    @productorderitems.each do |productorderitem|
        supplierpayment = Supplierpayment.where("to_char(date, 'MM-YYYY') = ? AND supplier_id = ?", "#{@month}-#{@year}", productorderitem.supplier_id).first

        if supplierpayment.nil?
          supplierpayment = Supplierpayment.new
          supplierpayment.supplier_id = productorderitem.supplier_id
          supplierpayment.date = Date.today.to_date
          supplierpayment.total = @productorderitems.where(:supplier_id => supplierpayment.supplier_id).sum(:total)
          supplierpayment.save
        else
          if supplierpayment.no_giro.blank?
            supplierpayment.total = @productorderitems.where(:supplier_id => supplierpayment.supplier_id).sum(:total)  
            supplierpayment.save
          end
        end
    end

    @supplierpayments = Supplierpayment.where("to_char(date, 'MM-YYYY') = ?", "#{@month}-#{@year}").order(:due_date)
  end

  def new
    @date = Date.today.strftime('%d-%m-%Y')
    @supplierpayment = Supplierpayment.new
    @supplierpayment.due_date = @supplierpayment.due_date.blank? ? @date : @supplierpayment.due_date.strftime('%d-%m-%Y') 
  end

  def edit
    @date = Date.today.strftime('%d-%m-%Y')
    @supplierpayment = Supplierpayment.find(params[:id])
    @supplierpayment.due_date = @supplierpayment.due_date.blank? ? @date : @supplierpayment.due_date.strftime('%d-%m-%Y') 
  end

  def create
  end

  def update
    inputs = params[:supplierpayment]
    @supplierpayment = Supplierpayment.find(params[:id])

    if @supplierpayment.update_attributes(inputs)
        @supplierpayment.save
        redirect_to(supplierpayments_path, :notice => 'Data Pembayaran telah disimpan')
    else
      render :action => 'edit'
    end
  end

  def destroy
  end

end
