  class OfficebankexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "officebankexpenses"
    @types = ['Kredit', 'Debit']
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @officeexpenses = Officebankexpense.where('date = ? AND bankexpense_id is not null', @date.to_date).order(:id)
  end

  def new
    @errors = Hash.new
    umum = Officeexpensegroup.find_by_name('Umum')

    @officeexpense = Officebankexpense.new
    @officeexpense.office_id = current_user.office_id rescue nil || 1 
    @officeexpense.enabled = true
    @officeexpense.date = Date.today.strftime('%d-%m-%Y')
    @officeexpense.expensetype = 'Kredit'
    @officeexpense.officeexpensegroup_id = umum.id
    @officeexpensegroups = Officeexpensegroup.active.where(:officeexpensegroup_id => @officeexpense.officeexpensegroup_id).order(:name)
    respond_to :html
  end

  def edit
    @errors = Hash.new 
    @officeexpense = Officebankexpense.find(params[:id])
    @officeexpense.date = @officeexpense.date.strftime('%d-%m-%Y') if !@officeexpense.date.blank?

    parentgroup = Officeexpensegroup.find(@officeexpense.officeexpensegroup_id) 
    if !parentgroup.officeexpensegroup_id.nil?
      @officeexpensegroups = Officeexpensegroup.active.where(:officeexpensegroup_id => parentgroup.officeexpensegroup_id).order(:name) 
    else
      @officeexpensegroups = Officeexpensegroup.active.where(:officeexpensegroup_id => parentgroup.id).order(:name)  
    end  
    
  end

  def create
    @errors = Hash.new 
    inputs = params[:officebankexpense]
    @officeexpense = Officebankexpense.new
    
    @officeexpense.office_id = inputs[:office_id]
    @officeexpense.expensetype = inputs[:expensetype]
    @officeexpense.date = inputs[:date].to_date
    @officeexpense.officeexpensegroup_id = inputs[:officeexpensegroup_id].blank? ? inputs[:parentofficeexpensegroup_id] : inputs[:officeexpensegroup_id]
    @officeexpense.vehicle_id = inputs[:vehicle_id]
    @officeexpense.total = inputs[:total]
    @officeexpense.description = inputs[:description]

    # Create Journal
    @bankexpense = Bankexpense.new
    @bankexpense.enabled = true
    @bankexpense.office_id = @officeexpense.office_id
    @bankexpense.date = @officeexpense.date
    @bankexpense.description = @officeexpense.description
    kas = Bankexpensegroup.where("UPPER(name) = ? ", 'KAS').first
    if @officeexpense.expensetype == 'Kredit'
      @bankexpense.debitgroup_id = inputs[:bankexpensegroup_id]
      @bankexpense.creditgroup_id = kas.id
    else
      @bankexpense.debitgroup_id = kas.id
      @bankexpense.creditgroup_id = inputs[:bankexpensegroup_id]
    end
    @bankexpense.total = inputs[:total].delete('.').gsub(",",".")

    if @bankexpense.save
      debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
      if !debit_to.nil?
        debit_to.total += @bankexpense.total
        debit_to.save
        updateofficecash @bankexpense.total, @bankexpense.date.strftime('%d-%m-%Y') if debit_to.name.upcase == 'KAS'
      end

      credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
      if !credit_to.nil?
        credit_to.total -= @bankexpense.total
        credit_to.save
        updateofficecash @bankexpense.total * -1, @bankexpense.date.strftime('%d-%m-%Y') if credit_to.name.upcase == 'KAS'
      end
    end
    @officeexpense.bankexpense_id = @bankexpense.id

    if @officeexpense.save
      redirect_to(officebankexpenses_url, :notice => 'Jurnal Petty Kas sukses di tambah.')
    else
      to_flash(@officebankexpense)
      render :action => "new"
    end
  end

  def update
    @errors = Hash.new 
    inputs = params[:officebankexpense]
    @officeexpense = Officebankexpense.find(params[:id])

    @officeexpense.office_id = inputs[:office_id]
    @officeexpense.date = inputs[:date].to_date
    @officeexpense.expensetype = inputs[:expensetype]
    @officeexpense.date = inputs[:date].to_date
    @officeexpense.officeexpensegroup_id = inputs[:officeexpensegroup_id].blank? ? inputs[:parentofficeexpensegroup_id] : inputs[:officeexpensegroup_id]
    @officeexpense.vehicle_id = inputs[:vehicle_id]
    @officeexpense.total = inputs[:total]
    @officeexpense.description = inputs[:description]

    # Create Journal
    @bankexpense = Bankexpense.find(@officeexpense.bankexpense_id)
    @bankexpense.enabled = true
    @bankexpense.office_id = @officeexpense.office_id
    @bankexpense.date = @officeexpense.date
    @bankexpense.description = @officeexpense.description
    kas = Bankexpensegroup.where("UPPER(name) = ? ", 'KAS').first
    if @officeexpense.expensetype == 'Kredit'
      @bankexpense.debitgroup_id = inputs[:bankexpensegroup_id]
      @bankexpense.creditgroup_id = kas.id
    else
      @bankexpense.debitgroup_id = kas.id
      @bankexpense.creditgroup_id = inputs[:bankexpensegroup_id]
    end
    @bankexpense.total = inputs[:total].delete('.').gsub(",",".")

    if @bankexpense.save
      debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
      if !debit_to.nil?
        debit_to.total += @bankexpense.total
        debit_to.save
        updateofficecash @bankexpense.total, @bankexpense.date.strftime('%d-%m-%Y') if debit_to.name.upcase == 'KAS'
      end

      credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
      if !credit_to.nil?
        credit_to.total -= @bankexpense.total
        credit_to.save
        updateofficecash @bankexpense.total * -1, @bankexpense.date.strftime('%d-%m-%Y') if credit_to.name.upcase == 'KAS'
      end
    end

    if @officeexpense.save
      redirect_to(officebankexpenses_url, :notice => 'Jurnal Petty Kas sukses di simpan.')
    else
      to_flash(@officebankexpense)
      render :action => "edit"
    end

  end

  def getofficeexpensegroup 
      group_id = params[:group_id]
      officegroup = Officeexpensegroup.where(:officeexpensegroup_id => group_id)

      render :json => {:success => true, :layout => false, :group => officegroup
              }.to_json;
  end

  def destroy
    @officeexpense = Officebankexpense.find(params[:id])
    @bankexpense = Bankexpense.find(@officeexpense.bankexpense_id)
    
    if @officeexpense.receiptexpenses.where(:deleted => false).any?
      redirect_to(officebankexpenses_url, :notice => 'Jurnal Petty Kas No. #' + zeropad(@officeexpense.id) +' tidak dapat dihapus. Harap hapus data yang sudah dikonfirmasi kasir terlebih dahulu.')
    else
      @officeexpense.deleteuser_id = current_user.id
      @officeexpense.deleted = true
      @officeexpense.save

      @bankexpense.deleteuser_id = current_user.id
      @bankexpense.deleted = true
      @bankexpense.save

      #testing koding untuk hapus
      debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
      if !debit_to.nil?
        updateofficecash @bankexpense.total * -1, @bankexpense.date.strftime('%d-%m-%Y') if debit_to.name.upcase == 'KAS'
      end

      credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
      if !credit_to.nil?
        updateofficecash @bankexpense.total, @bankexpense.date.strftime('%d-%m-%Y') if credit_to.name.upcase == 'KAS'
      end
      #===========================#

      redirect_to(officebankexpenses_url)
    end
    
  end  
  
  def enable
    @officeexpense = Officebankexpense.find(params[:id])
    @officeexpense.update_attributes(:enabled => true)
    redirect_to(officeexpenses_url)
  end
  
  def disable
    @officeexpense = Officebankexpense.find(params[:id])
    @officeexpense.update_attributes(:enabled => false)
    redirect_to(officeexpenses_url)
  end
end
