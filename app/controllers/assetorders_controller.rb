class AssetordersController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "transactions"
    @where = "assetorders"
    @asset_types = ["Lancar", "Tidak Lancar"]
  end

  def index
    @date = params[:date]
    @date = Date.today.strftime('%d-%m-%Y') if @date.nil?
    @assetorders = Assetorder.active.all
    respond_to :html
  end

  def new
    @assetorder = Assetorder.new
    @assetorder.date = Date.today.strftime('%d-%m-%Y')
  end

  def edit
    @assetorder = Assetorder.find(params[:id])
  end

  def create
    inputs = params[:assetorder]
    @assetorder = Assetorder.new(inputs)
    @assetorder.unit_price = clean_currency(inputs[:unit_price])
    @assetorder.total = clean_currency(inputs[:total])
    @assetorder.user_id = current_user.id
    if @assetorder.save
      createbankexpenserecord @assetorder.id
      redirect_to(assetorders_path, :notice => 'Data Pembelian Aset sukses di tambah.')
    else
      to_flash(@assetorder)
      render :action => "new"
    end
  end

  def update
    inputs = params[:assetorder]
    @assetorder = Assetorder.find(params[:id])

    if @assetorder.update_attributes(inputs)
      @assetorder.unit_price = clean_currency(inputs[:unit_price])
      @assetorder.total = clean_currency(inputs[:total])
      @assetorder.user_id = current_user.id
      @assetorder.save

      createbankexpenserecord @assetorder.id
      redirect_to(edit_assetorder_url(@assetorder), :notice => 'Data Pembelian Aset sukses di simpan.')
    else
      to_flash(@assetorder)
      render :action => "edit"
    end
  end

  def destroy
    @assetorder = Assetorder.find(params[:id])
    @assetorder.deleted = true
    @assetorder.deleteuser_id = current_user.id
    @assetorder.save

    destroybankexpenserecord @assetorder.id
    redirect_to(assetorders_url)
  end  

  def createbankexpenserecord assetorder_id
      @assetorder = Assetorder.find(assetorder_id) rescue nil
      
      if @assetorder
        debitgroup = Bankexpensegroup.find_by_name("Aktiva") rescue nil
        creditgroup = Bankexpensegroup.find_by_name("Hutang Aktiva") rescue nil
        
        @bankexpense = Bankexpense.where(:assetorder_id => assetorder_id, :debitgroup_id => debitgroup.id, :creditgroup_id => creditgroup.id, :deleted => false).first
        
        needupdate = @bankexpense.nil? ? false : true

        @bankexpense = Bankexpense.new if @bankexpense.nil?
        
        @bankexpense.debitgroup_id = debitgroup.id
        @bankexpense.creditgroup_id = creditgroup.id
        @bankexpense.assetorder_id = @assetorder.id
        @bankexpense.description = "Pembelian Aktiva #" + zeropad(@assetorder.id) 
        @bankexpense.date = @assetorder.date
        
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

        @bankexpense.total = @assetorder.total

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

    def destroybankexpenserecord assetorder_id
      debitgroup = Bankexpensegroup.find_by_name("Aktiva") rescue nil
      creditgroup = Bankexpensegroup.find_by_name("Hutang Aktiva") rescue nil
        
      bankexpense = Bankexpense.where(:assetorder_id => assetorder_id, :debitgroup_id => debitgroup.id, :creditgroup_id => creditgroup.id, :deleted => false).first rescue nil
      
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