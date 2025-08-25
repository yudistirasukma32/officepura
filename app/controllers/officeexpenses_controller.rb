  class OfficeexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "officeexpenses"
    @types = ['Kredit', 'Debit']
  end

  def index
    #@date = params[:date]
    #@date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    # @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @officeexpenses = Officeexpense.where('date between ? and ?', @startdate.to_date, @enddate.to_date).order(:id)
  end

  def new
    @parentgroups = Bankexpensegroup.active.parentgroup.order(:name)

    @errors = Hash.new
    umum = Officeexpensegroup.find_by_name('UMUM')

    @officeexpense = Officeexpense.new
    @officeexpense.office_id = current_user.office_id rescue nil || 1 
    @officeexpense.enabled = true
    @officeexpense.date = Date.today.strftime('%d-%m-%Y')
    @officeexpense.expensetype = 'Kredit'
    @officeexpense.officeexpensegroup_id = umum.id
    @officeexpensegroups = Officeexpensegroup.active.where(:officeexpensegroup_id => @officeexpense.officeexpensegroup_id).order(:name)
    respond_to :html
  end

  def edit
    @parentgroups = Bankexpensegroup.active.parentgroup.order(:name)


    @errors = Hash.new 
    @officeexpense = Officeexpense.find(params[:id])
    @officeexpense.date = @officeexpense.date.strftime('%d-%m-%Y') if !@officeexpense.date.blank?
   
    #for group dropdown_items
    @childgroups = Bankexpensegroup.where(:id => @officeexpense.bankexpensegroup_id) rescue nil
    @parentgroup_id = Bankexpensegroup.find(@officeexpense.bankexpensegroup_id).bankexpensegroup_id rescue nil
    @childgroup_id = @officeexpense.bankexpensegroup_id
    #=========#

    parentgroup = Officeexpensegroup.find(@officeexpense.officeexpensegroup_id) 
    if !parentgroup.officeexpensegroup_id.nil?
      @officeexpensegroups = Officeexpensegroup.active.where(:officeexpensegroup_id => parentgroup.officeexpensegroup_id).order(:name) 
    else
      @officeexpensegroups = Officeexpensegroup.active.where(:officeexpensegroup_id => parentgroup.id).order(:name)  
    end  
    
  end

  def create
    @errors = Hash.new 
    inputs = params[:officeexpense]
    @officeexpense = Officeexpense.new

    @officeexpense.office_id = inputs[:office_id]
    @officeexpense.expensetype = inputs[:expensetype]
    @officeexpense.date = inputs[:date].to_date
    @officeexpense.officeexpensegroup_id = inputs[:officeexpensegroup_id].blank? ? inputs[:parentofficeexpensegroup_id] : inputs[:officeexpensegroup_id]
    @officeexpense.vehicle_id = inputs[:vehicle_id]
    @officeexpense.container_id = inputs[:container_id]
    @officeexpense.isotank_id = inputs[:isotank_id]
    @officeexpense.total = inputs[:total]
    @officeexpense.description = inputs[:description]
    @officeexpense.event_id = inputs[:event_id]

    if inputs[:taxinvoiced] == 'Yes'
      @officeexpense.taxinvoiced = true
      @officeexpense.customer_id = inputs[:customer_id]
      @officeexpense.taxinvoice_item_name = inputs[:taxinvoice_item_name]
    else
      @officeexpense.taxinvoiced = false
      @officeexpense.customer_id = nil
      @officeexpense.taxinvoice_item_name = nil
    end

    #add bankexpensegroup_id
    @officeexpense.bankexpensegroup_id = inputs[:bankexpensegroup_id]
    #======

    if @officeexpense.save
      redirect_to(officeexpenses_url(:date => @officeexpense.date.strftime('%d-%m-%Y')), :notice => 'Kas Kantor sukses di tambah.')
    else
      to_flash(@officeexpense)
      render :action => "new"
    end
  end

  def update
    @errors = Hash.new 
    inputs = params[:officeexpense]
    @officeexpense = Officeexpense.find(params[:id])

    @officeexpense.office_id = inputs[:office_id]
    @officeexpense.date = inputs[:date].to_date
    @officeexpense.expensetype = inputs[:expensetype]
    @officeexpense.date = inputs[:date].to_date
    @officeexpense.officeexpensegroup_id = inputs[:officeexpensegroup_id].blank? ? inputs[:parentofficeexpensegroup_id] : inputs[:officeexpensegroup_id]
    @officeexpense.vehicle_id = inputs[:vehicle_id]
    @officeexpense.container_id = inputs[:container_id]
    @officeexpense.isotank_id = inputs[:isotank_id]
    @officeexpense.total = inputs[:total]
    @officeexpense.description = inputs[:description]
    @officeexpense.event_id = inputs[:event_id]

    if inputs[:taxinvoiced] == 'Yes'
      @officeexpense.taxinvoiced = true
      @officeexpense.customer_id = inputs[:customer_id]
      @officeexpense.taxinvoice_item_name = inputs[:taxinvoice_item_name]
    else
      @officeexpense.taxinvoiced = false
      @officeexpense.customer_id = nil
      @officeexpense.taxinvoice_item_name = nil
    end

    if @officeexpense.save
      redirect_to(officeexpenses_url(:date => @officeexpense.date.strftime('%d-%m-%Y')), :notice => 'Kas Kantor sukses di simpan.')
    else
      to_flash(@officeexpense)
      render :action => "edit"
    end

  end

  def getofficeexpensegroup 
      group_id = params[:group_id]
      officegroup = Officeexpensegroup.where(:officeexpensegroup_id => group_id)

      render :json => {:success => true, :layout => false, :group => officegroup
              }.to_json;
  end

  def getbankexpensegroup 
      group_id = params[:bankgroup_id]
      # @childgroups = Bankexpensegroup.where(:bankexpensegroup_id => group_id).where("id NOT IN (6,19)").order(:name)
      @childgroups = Bankexpensegroup.active.where(:bankexpensegroup_id => group_id).order(:name)


      render :json => {:success => true, :layout => false, :group => @childgroups
              }.to_json;
  end

  def destroy
    @officeexpense = Officeexpense.find(params[:id])
    
    if @officeexpense.receiptexpenses.where(:deleted => false).any?
      redirect_to(officeexpenses_url, :notice => 'Kas Harian No. #' + zeropad(@officeexpense.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
      @officeexpense.deleteuser_id = current_user.id
      @officeexpense.deleted = true
      @officeexpense.save
      redirect_to(officeexpenses_url(:date => @officeexpense.date.strftime('%d-%m-%Y')))
    end
    
  end  
  
  def enable
    @officeexpense = Officeexpense.find(params[:id])
    @officeexpense.update_attributes(:enabled => true)
    redirect_to(officeexpenses_url(:date => @officeexpense.date.strftime('%d-%m-%Y')))
  end
  
  def disable
    @officeexpense = Officeexpense.find(params[:id])
    @officeexpense.update_attributes(:enabled => false)
    redirect_to(officeexpenses_url(:date => @officeexpense.date.strftime('%d-%m-%Y')))
  end
end
