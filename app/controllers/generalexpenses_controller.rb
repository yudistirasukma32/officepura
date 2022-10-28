  class GeneralexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section
  protect_from_forgery :except => [:create]

  def set_section
    @section = "transactions2"
    @where = "generalexpenses"
    @types = ['Debit', 'Kredit']
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    
    @generalexpensegroup = Officeexpensegroup.find_by_name("Umum") rescue nil
    if @generalexpensegroup.nil?
      @generalexpensegroup = Officeexpensegroup.new
      @generalexpensegroup.name = "Umum"
      @generalexpensegroup.save
    end

    @generalexpenses = Officeexpense.where('date = ? AND officeexpensegroup_id = ?', @date.to_date, @generalexpensegroup.id).order(:id)
  end

  def new
    @errors = Hash.new
    @generalexpense = Officeexpense.new
    @generalexpensegroup = Officeexpensegroup.find_by_name("Umum")
    @generalexpensesgroup_id = @generalexpensegroup.id
    
    @officeexpense_id = params[:officeexpense_id]
    @generalexpense = Officeexpense.find(params[:officeexpense_id]) rescue nil || Officeexpense.new

    @generalexpense.enabled = true
    @generalexpense.date = Date.today.strftime('%d-%m-%Y') if @generalexpense.date.blank?
    respond_to :html
  end

  def create
    @errors = Hash.new 
    @generalexpense = Officeexpense.new
    inputs = params[:generalexpense]
    @Officeexpense_id = inputs[:officeexpense_id]
    @generalexpense = Officeexpense.find(inputs[:officeexpense_id]) rescue nil || Officeexpense.new
    

    office = Office.find_by_name("Surabaya") rescue nil
    @generalexpense.office_id = office.id || 1
    @generalexpense.expensetype = inputs[:expensetype]
    @generalexpense.officeexpensegroup_id = inputs[:officeexpensegroup_id]
    @generalexpense.vehicle_id = inputs[:vehicle_id]
    @generalexpense.total = inputs[:total]
    @generalexpense.date = inputs[:date].to_date
    @generalexpense.enabled = true
    @generalexpense.description = inputs[:description]

    if @generalexpense.save
      redirect_to("/generalexpenses/new/" + @generalexpense.id.to_s, :notice => 'Kas Umum sukses di tambah.')
    else
      redirect_to("/generalexpenses/new/" + @generalexpense.id.to_s)
    end
  end

  def destroy
    @generalexpense = Officeexpense.find(params[:id])

    if @generalexpense.receiptexpenses.where(:deleted => false).any?
      redirect_to(generalexpenses_url, :notice => 'Kas Harian No. #' + zeropad(@generalexpense.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
      @generalexpense.deleted = true
      @generalexpense.save  
      redirect_to(generalexpenses_url)
    end
  end  
  
  def enable
    @generalexpense = Officeexpense.find(params[:id])
    @generalexpense.update_attributes(:enabled => true)
    redirect_to(generalexpenses_url)
  end
  
  def disable
    @generalexpense = Officeexpense.find(params[:id])
    @generalexpense.update_attributes(:enabled => false)
    redirect_to(generalexpenses_url)
  end
end
