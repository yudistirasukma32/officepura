class IncentivesController < ApplicationController
	include ApplicationHelper
	include ActionView::Helpers::NumberHelper
	layout "application", :except => []
	protect_from_forgery :except => [:new, :index, :updateitems]
	before_filter :authenticate_user!, :set_section

	def set_section
		@section = "transactions"
		@where = "incentives"
	end

	def index
		@startdate = params[:startdate] || Date.today.at_beginning_of_month.strftime('%d-%m-%Y') 
		@enddate = params[:enddate] || (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')

		@invoices = Invoice.active.where("date BETWEEN :startdate AND :enddate AND money(incentive) > money(0) and id not in (SELECT invoice_id FROM incentives where deleted=false )", {:startdate => @startdate.to_date, :enddate => @enddate.to_date}).order(:id)
		puts @invoices.count
		respond_to :html
	end

	def index_confirmed
		@startdate = params[:startdate] || Date.today.at_beginning_of_month.strftime('%d-%m-%Y') 
		@enddate = params[:enddate] || (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y')
    @incentives = Incentive.where("created_at >= ? and created_at < ?", @startdate.to_date, @enddate.to_date + 1.day).order(:id)
		respond_to :html
	end

	def show
		@incentive = Incentive.find(params[:id])
		respond_to :html
	end

	def new
		@errors = Hash.new
		@incentive = Incentive.new
		@incentive.invoice_id = params[:invoice_id]		
		@invoice = @incentive.invoice

		@incentive.quantity = @invoice.quantity
		@incentive.quantity -= @invoice.receiptreturns.active.sum(:quantity) if @invoice.receiptreturns.active.any?

		@incentive.total = @incentive.quantity * @invoice.incentive
	end

  def create
    inputs = params[:incentive]
    @incentive = Incentive.new(inputs)
		@incentive.user_id = current_user.id

    if @incentive.save
      redirect_to(incentive_url(@incentive), :notice => 'Data Incentive sukses di tambah.')
    else
      to_flash(@incentive)
      render :action => "new"
    end
  end

	def destroy
		@receipt = Incentive.find(params[:id])
	 
		if @receipt.receiptincentives.where(:deleted => false).any?
			redirect_to(incentives_url, :notice => 'Incentive BKK No. #' + zeropad(@receipt.invoice.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
		else
			@receipt.deleteuser_id = current_user.id
			@receipt.deleted = true
			@receipt.save
			redirect_to(incentives_url)
		end
	end  

end
