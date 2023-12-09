class InvoicetrainsController < ApplicationController
  include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role

	def set_section
    @section = "transactions"
    @where = "invoicetrains"
    @train_status = ["Empty", "Titip"]
  end

  def set_role
    @user_role = 'Admin Operasional'
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @enddate =  @enddate.nil? ? Date.today.strftime('%d-%m-%Y') : params[:enddate]
    @station_id = params[:station_id]
    @activity = params[:activity_type]
    @operator_id = params[:operator_id]

    @invoicetrains = Invoicetrain.active.where("date between ? and ?", @date.to_date, @enddate.to_date).order(:id)

    if @station_id.present?
      @invoicetrains = @invoicetrains.where('station_id = ?', @station_id)
    end

    if @operator_id.present?
      @invoicetrains = @invoicetrains.where('operator_id = ?', @operator_id)
    end

    if @activity.present?
      @invoicetrains = @invoicetrains.where('activity_type = ?', @activity)
    end
    respond_to :html
  end

  def new
    @invoicetrain = Invoicetrain.new
    @invoicetrain.enabled = true
    @invoicetrain.date = Date.today.strftime('%d-%m-%Y')
    # @invoicetrain.container_type = 'Container'
    respond_to :html
  end

  def edit
    @process = 'edit'
    @invoicetrain = Invoicetrain.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:invoicetrain]
    if inputs['container_type'] == 'Isotank'
      inputs['container_id'] = nil
    else
      inputs['isotank_id'] = nil
    end
    @invoicetrain = Invoicetrain.new(inputs)

    if @invoicetrain.save
      redirect_to(invoicetrains_url(), :notice => 'Data BKK Truk via Kereta sukses dibuat.')
    else
      redirect_to(new_invoicetrain_url(), :notice => 'Data BKK Truk via Kereta gagal dibuat.')
    end
  end

  def update
    inputs = params[:invoicetrain]
    @invoicetrain = Invoicetrain.find(params[:id])
    
    if inputs['container_type'] == 'Isotank'
      inputs['container_id'] = nil
    else
      inputs['isotank_id'] = nil
    end

    if @invoicetrain.update_attributes(inputs)
      @invoicetrain.save
      redirect_to(edit_invoicetrain_url(@invoicetrain), :notice => 'Data BKK Truk via Kereta sukses disimpan.')
    else
      redirect_to(edit_invoicetrain_url(@invoicetrain), :notice => 'Data BKK Truk via Kereta ngagal disimpan.')
    end
  end

  def destroy
    @invoicetrain = Invoicetrain.find(params[:id])
    @invoicetrain.deleted = true
    @invoicetrain.deleteuser_id = current_user.id
    @invoicetrain.save
    redirect_to(invoicetrains_url)
  end  
  
  def enable
    @invoicetrain = Invoicetrain.find(params[:id])
    @invoicetrain.update_attributes(:enabled => true)
    redirect_to(invoicetrains_url)
  end
  
  def disable
    @invoicetrain = Invoicetrain.find(params[:id])
    @invoicetrain.update_attributes(:enabled => false)
    redirect_to(invoicetrains_url)
  end

end

