class ContractsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_contract
	before_filter :set_contract, only: [:edit, :update, :destroy]

  respond_to :html
	
	def set_section
    @section = "masters"
    @where = "contracts"
  end

  def set_contract
    @contract = Contract.find(params[:id])
  end

  def index
    @contracts = Contract.all
    respond_with(@contracts)
  end

  def addnew
    @contract = Contract.new
    respond_to :html
  end

  def new
    @contract = Contract.new
    @process = 'new'
    
    if params[:format].present?
      @customer = Customer.find(params[:format])
      @contract.customer_id = @customer.id
      @contract.enabled = true  
    end
    # respond_to :html
  end

  def edit
    @process = 'edit'
  	respond_with(@contract)
  end

  def create
    @contract = Contract.new(params[:contract])
    customer_id = params[:contract][:customer_id]
    @contract.save
		redirect_to(edit_customer_url(customer_id)+'/#3', :notice => 'Data Kontrak sukses disimpan')
  end

  def update
    if @contract.update_attributes(params[:contract])
      customer_id = params[:contract][:customer_id]
      @contract.save
      redirect_to(edit_customer_url(customer_id)+'/#3', :notice => 'Data Kontrak sukses diupdate')
    else
      to_flash(@contract)
      render :action => "edit"
    end
  end

  def destroy
    @contract = Contract.find(params[:id])
    customer_id = @contract.customer_id
    @contract.deleted = true
    @contract.save
		redirect_to(edit_customer_url(customer_id)+'/#3', :notice => 'Data Kontrak sukses dihapus')
  end

  def enable
    @contract = Contract.find(params[:id])
    customer_id = @contract.customer_id
    @contract.update_attributes(:enabled => true)
    redirect_to(edit_customer_url(customer_id)+'/#3')
  end
  
  def disable
    @contract = Contract.find(params[:id])
    customer_id = @contract.customer_id
    @contract.update_attributes(:enabled => false)
    redirect_to(edit_customer_url(customer_id)+'/#3')
  end

  # private
  #   def set_contract
  #     @contract = Contract.find(params[:id])
  #   end

  #   def permitted_params
  #     {:contract => params.fetch(:contract, {}).permit(
  #       :name, :code, :date_start, :date_end, :customer_id, :contract_type, 
  #       :description, :enabled, :deleted, :total
  #     )}
  #   end
end

