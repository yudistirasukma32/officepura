class BankexpensesController < ApplicationController
  include ApplicationHelper
  layout "application"
  before_filter :authenticate_user!, :set_section

  $globalDate = Date.today.strftime('%d-%m-%Y')

  def set_section
    @section = "transactions"
    @bankexpense = Bankexpense.find(params[:id]) rescue nil
    bankledger = @bankexpense.nil? ? false : @bankexpense.bankledger
    if params[:bankledger] == '1' || bankledger
      @where = "bankinvoices"
    else
      @where = "bankexpenses"
    end
    @types = ['Debit', 'Kredit']
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    $globalDate = @date
    @bankexpenses = Bankexpense.where("bankledger IS FALSE AND pettycashledger IS FALSE AND to_char(date, 'DD-MM-YYYY') = ?", @date).order(:id)
  end

  def new
    @bankledger = params[:bankledger] == '1' ? 1 : nil
    if !@bankledger.nil?
      @parentgroups = Bankexpensegroup.active.parentgroup.where("name NOT LIKE 'PETTY KAS'").order(:name)
      @bankgroups = Bankexpensegroup.active.parentgroup.where("name LIKE 'BANK'").order(:name)
    else
      @parentgroups = Bankexpensegroup.active.parentgroup.order(:name)
    end

    @bankexpense = Bankexpense.new
    @bankexpense.enabled = true
    @bankexpense.office_id = current_user.office_id rescue nil || 1 
    @bankexpense.date = Date.today.strftime('%d-%m-%Y')
    respond_to :html
  end

  def edit
    @bankexpense = Bankexpense.find(params[:id])
    @bankexpense.date = @bankexpense.date.strftime('%d-%m-%Y') if !@bankexpense.date.blank?
    @parentgroups = Bankexpensegroup.active.parentgroup.order(:name)

    @childgroupsdebit = Bankexpensegroup.where(:id => @bankexpense.debitgroup_id)
    @childgroupscredit = Bankexpensegroup.where(:id => @bankexpense.creditgroup_id)

    @childdebitgroup_id = Bankexpensegroup.find(@bankexpense.debitgroup_id).id
    @childcreditgroup_id = Bankexpensegroup.find(@bankexpense.creditgroup_id).id

    @parentdebitgroup_id = Bankexpensegroup.find(@bankexpense.debitgroup_id).bankexpensegroup_id
    @parentcreditgroup_id = Bankexpensegroup.find(@bankexpense.creditgroup_id).bankexpensegroup_id
  end

  def create
    inputs = params[:bankexpense]

    @bankexpense = Bankexpense.new(inputs)
    @bankexpense.total = inputs[:total].delete('.').gsub(",",".")

    if !@bankexpense.money_in.nil?
      if !@bankexpense.money_in && @bankexpense.bankledger
        debit = @bankexpense.creditgroup_id
        @bankexpense.creditgroup_id = @bankexpense.debitgroup_id
        @bankexpense.debitgroup_id = debit
      end
    end

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

      if @bankexpense.bankledger
        redirect_to(bankinvoices_url(:date => @bankexpense.date.strftime('%d-%m-%Y')), :notice => 'Kas Bank sukses di tambah.')
      else
        redirect_to(bankexpenses_url(:date => @bankexpense.date.strftime('%d-%m-%Y')), :notice => 'Kas Bank sukses di tambah.')
      end
    else
      redirect_to request.referrer
    end
  end

  def update
    inputs = params[:bankexpense]
    @bankexpense = Bankexpense.find(params[:id])

    #return total value first before saving new ones
    tmp_debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
    tmp_credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
    tmp_total = @bankexpense.total

    @pastdate = @bankexpense.date.strftime('%d-%m-%Y')

    if @bankexpense.update_attributes(inputs)
      @bankexpense.total = inputs[:total].delete('.').gsub(",",".")
      
      if @bankexpense.save

        # update old value
        if !tmp_debit_to.nil?
          tmp_debit_to.total -= tmp_total
          tmp_debit_to.save
          updateofficecash tmp_total * -1, @pastdate if tmp_debit_to.name.upcase == 'KAS'
        end

        if !tmp_credit_to.nil?
          tmp_credit_to.total += tmp_total
          tmp_credit_to.save
          updateofficecash tmp_total, @pastdate if tmp_credit_to.name.upcase == 'KAS'
        end

        # new value
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
      if @bankexpense.bankledger
        redirect_to(bankinvoices_url(:date => @bankexpense.date.strftime('%d-%m-%Y')), :notice => 'Kas Bank sukses di tambah.')
      else
        redirect_to(bankexpenses_url(:date => @bankexpense.date.strftime('%d-%m-%Y')), :notice => 'Kas Bank sukses di tambah.')
      end
    else
      to_flash(@bankexpense)
      render :action => "edit"
    end
  end

  def destroy
    @bankexpense = Bankexpense.find(params[:id])
   
    if @bankexpense
      tmp_debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
      tmp_credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
      tmp_total = @bankexpense.total

      # update old value
      if !tmp_debit_to.nil?
        tmp_debit_to.total -= tmp_total
        tmp_debit_to.save
        updateofficecash tmp_total * -1, @bankexpense.date.strftime('%d-%m-%Y') if tmp_debit_to.name.upcase == 'KAS'
      end

      if !tmp_credit_to.nil?
        tmp_credit_to.total += tmp_total
        tmp_credit_to.save
        updateofficecash tmp_total, @bankexpense.date.strftime('%d-%m-%Y') if tmp_credit_to.name.upcase == 'KAS'
      end

      @bankexpense.deleteuser_id = current_user.id
    end
    
    @bankexpense.deleted = true
    @bankexpense.save
    if @bankexpense.bankledger
      redirect_to(bankinvoices_url, :notice => 'Kas Bank sukses di hapus dan data nominal grup sukses di update.')
    else
      redirect_to(bankexpenses_url, :notice => 'Kas Bank sukses di hapus dan data nominal grup sukses di update.')
    end
    
  end

  def getbankexpensegroupdebit 
    group_id = params[:group_id]
    @childgroupsdebit = Bankexpensegroup.active.where(:bankexpensegroup_id => group_id).order(:name)

    render :json => {:success => true, :layout => false, :group => @childgroupsdebit
            }.to_json;
  end

  def getbankexpensegroupcredit
    group_id = params[:group_id]
    @childgroupscredit = Bankexpensegroup.active.where(:bankexpensegroup_id => group_id).order(:name)
    render :json => {:success => true, :layout => false, :group => @childgroupscredit
            }.to_json;
  end  
  
  def enable
    @bankexpense = Bankexpense.find(params[:id])
    @bankexpense.update_attributes(:enabled => true)
    redirect_to(bankexpenses_url)
  end
  
  def disable
    @bankexpense = Bankexpense.find(params[:id])
    @bankexpense.update_attributes(:enabled => false)
    redirect_to(bankexpenses_url)
  end
end
