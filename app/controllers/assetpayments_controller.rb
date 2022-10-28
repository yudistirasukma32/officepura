class AssetpaymentsController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "assetpayments"
    @asset_types = ["Lancar", "Tidak Lancar"]
  end

  def index
    @assetorders = Assetorder.active.all
  end

  def index_confirmed
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @assetpayments = Assetpayment.all
    respond_to :html
  end

  def new
    @assetorder = Assetorder.find(params[:assetorder_id]) rescue nil 
    @assetorder_id = @assetorder.id
    @assetpayment = Assetpayment.new
    @assetpayment.date = Date.today.strftime('%d-%m-%Y')
  end

  def edit
    
  end

  def create
    inputs = params[:assetpayment]
    @assetpayment = Assetpayment.new(inputs)
    @assetpayment.total = clean_currency(inputs[:total])
    @assetpayment.user_id = current_user.id
    if @assetpayment.save
      createbankexpenserecord @assetpayment.id
      redirect_to(assetpayments_path, :notice => 'Data Pembayaran Aset sukses di tambah.')
    else
      to_flash(@assetpayment)
      render :action => "new"
    end
  end

  def update
    inputs = params[:assetpayment]
    @assetpayment = Assetpayment.find(params[:id])

    if @assetpayment.update_attributes(inputs)
      @assetpayment.total = clean_currency(inputs[:total])
      @assetpayment.user_id = current_user.id
      @assetpayment.save

      createbankexpenserecord @assetpayment.id
      redirect_to(assetpayments_path, :notice => 'Data Pembayaran Aset sukses di simpan.')
    else
      to_flash(@assetpayment)
      render :action => "edit"
    end
  end

  def destroy
    @assetpayment = Assetpayment.find(params[:id])
    @assetpayment.deleted = true
    @assetpayment.deleteuser_id = current_user.id
    @assetpayment.save

    destroybankexpenserecord @assetpayment.id
    redirect_to(assetpayments_url)
  end  

  def createbankexpenserecord assetpayment_id
      @assetpayment = Assetpayment.find(assetpayment_id) rescue nil
      
      if @assetpayment
        debitgroup = Bankexpensegroup.find_by_name("Hutang Aktiva") rescue nil
        creditgroup = Bankexpensegroup.find_by_name("BANK Mandiri Toko 142 00 12738653") rescue nil
        
        @bankexpense = Bankexpense.where(:assetpayment_id => assetpayment_id, :debitgroup_id => debitgroup.id, :creditgroup_id => creditgroup.id, :deleted => false).first
        
        needupdate = @bankexpense.nil? ? false : true

        @bankexpense = Bankexpense.new if @bankexpense.nil?
        
        @bankexpense.debitgroup_id = debitgroup.id
        @bankexpense.creditgroup_id = creditgroup.id
        @bankexpense.assetpayment_id = @assetpayment.id
        @bankexpense.description = "Pembayaran Aktiva #" + zeropad(@assetpayment.id) 
        @bankexpense.date = @assetpayment.date
        
        if needupdate
          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
          if !debit_to.nil?
            debit_to.total -= @bankexpense.total
            debit_to.save
          end

          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
          if !credit_to.nil?
            credit_to.total += @bankexpense.total
            credit_to.save
          end
        end

        @bankexpense.total = @assetpayment.total

        if @bankexpense.save
          debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
          if !debit_to.nil?
            debit_to.total += @bankexpense.total
            debit_to.save
          end

          credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
          if !credit_to.nil?
            credit_to.total -= @bankexpense.total
            credit_to.save
          end
        end
      end
    end

    def destroybankexpenserecord assetpayment_id
      debitgroup = Bankexpensegroup.find_by_name("Hutang Aktiva") rescue nil
      creditgroup = Bankexpensegroup.find_by_name("BANK Mandiri 142.00.1186602.6") rescue nil
        
      bankexpense = Bankexpense.where(:assetpayment_id => assetpayment_id, :debitgroup_id => debitgroup.id, :creditgroup_id => creditgroup.id, :deleted => false).first rescue nil
      
      if bankexpense
        bankexpense.deleted = true
        bankexpense.deleteuser_id = current_user.id
        
        if bankexpense.save
          if !@bankexpense.debitgroup_id.nil?
            debit_to = Bankexpensegroup.find(@bankexpense.debitgroup_id) rescue nil
              if !debit_to.nil?
                  debit_to.total -= @bankexpense.total
                  debit_to.save
              end
          end

          if !@bankexpense.creditgroup_id.nil?
              credit_to = Bankexpensegroup.find(@bankexpense.creditgroup_id) rescue nil
              if !credit_to.nil?
                  credit_to.total += @bankexpense.total
                  credit_to.save
              end
          end
        end
      end
  end
end