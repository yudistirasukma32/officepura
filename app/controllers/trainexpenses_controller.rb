class TrainexpensesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section, :set_role
  protect_from_forgery :except => [:update_asset]

  def set_section
    @section = "trainexpenses"
    @where = "trainexpenses"
    @contype = ["ISOTANK 20FT", "ISOTANK EMPTY 20FT", "DRY CONTAINER EMPTY 20FT", "DRY CONTAINER 20FT", "DRY CONTAINER EMPTY 40FT", "DRY CONTAINER 40FT"]
    @consize = ["20FT", "40FT"]
  end

  def set_role
    @user_role = 'Admin Operasional, Admin Keuangan'
  end

  def index
    @where = "trainexpenses"

    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @operator_id = params[:operator_id]
    @containertype = params[:containertype]

    @trainexpenses = Invoice.where('invoicetrain = true AND routetrain_id is not null AND routetrain_id !=0  AND date between ? and ? AND invoices.id not in (select invoice_id from trainexpenses where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)

    if @operator_id.present?
      @trainexpenses = @trainexpenses.where('invoices.operator_id = ?', @operator_id)
    end

    if @containertype.present?
      @trainexpenses = @trainexpenses.joins(:routetrain).where('routetrains.container_type = ?', @containertype)
    end
  end

  def download_excel
    params[:startdate] = params[:startdate].present? ? params[:startdate] : Date.at_beginning_of_month
    params[:enddate] = params[:enddate].present? ? params[:enddate] : Date.today

    trainexpenses = Invoice.where('invoicetrain = true AND routetrain_id is not null AND routetrain_id !=0  AND date between ? and ? AND invoices.id not in (select invoice_id from trainexpenses where deleted = false)', params[:startdate].to_date, params[:enddate].to_date).order(:id)

    if params[:operator_id].present?
      trainexpenses = trainexpenses.where('invoices.operator_id = ?', params[:operator_id])
    end

    if params[:containertype].present?
      trainexpenses = trainexpenses.joins(:routetrain).where('routetrains.container_type = ?', params[:containertype])
    end

    title = "Biaya Operator Kereta Periode #{params[:startdate]} s/d #{params[:enddate]}"

    green = Axlsx::Color.new :rgb => "FF00FF00"
    red = Axlsx::Color.new :rgb => "FFCC0033"
    p = Axlsx::Package.new
    p.workbook.add_worksheet(name: "Biaya Operator Kereta") do |sheet|
      bold = sheet.styles.add_style(:b => true)
      right = sheet.styles.add_style(:alignment => {:horizontal => :right})
      right_bold = sheet.styles.add_style(:alignment => {:horizontal => :right}, :b => true)
      h1 = sheet.styles.add_style :b => true, :sz => 16
      h2 = sheet.styles.add_style :b => true, :sz => 14
      h3_green = sheet.styles.add_style :color => green, :b => true
      h3_red = sheet.styles.add_style :color => red, :b => true
      number = sheet.styles.add_style :format_code => "#,##0.00"
      number_green = sheet.styles.add_style :format_code => "#,##0.00", :color => green, :b => true
      number_red = sheet.styles.add_style :format_code => "#,##0.00", :color => red, :b => true
      wrap_txt = sheet.styles.add_style(:alignment => {:wrap_text => true, :shrink_to_fit => true})

      sheet.merge_cells "B2:L2"
      sheet.merge_cells "B4:L4"
      sheet.add_row [''], :height => 20
      sheet.add_row ['', "Dibuat pada Tanggal: #{Date.today.strftime('%d %B %Y')} (#{Time.now.strftime('%H:%M')})"], :height => 20, :style => [nil, bold]

      sheet.add_row [''], :height => 20
      sheet.add_row ['',Setting.find_by_name("Client Name").value.to_s + " / Biaya Operator Kereta: " + params[:startdate].to_date.strftime('%d %B %Y') + " s/d " + params[:enddate].to_date.strftime('%d %B %Y')] , :height => 20, :widths => [:auto, :ignore], :style => [nil, h1]

      sheet.add_row [''], :height => 20
      sheet.add_row ['','NO', 'TANGGAL', 'NO. BKK', 'KETERANGAN', 'JURUSAN KERETA', 'NOPOL', 'KONTAINER/ISO', 'NO. DO', 'TYPE', 'OPERATOR', 'TOTAL'] , :height => 20, :style => [nil, bold, bold, bold, bold, bold, bold, bold, bold, bold, bold, right_bold], :widths => [5, 5, :auto, :auto, :auto, :auto, :auto, :auto, :auto, :auto, :auto, :auto]
      # render json: sheet.rows.last.index
      # return false

      grandtotal = 0
      trainexpenses.each_with_index do |invoice, i|
        # Special price change for BKE. Make sure to change the price in _form.html.erb && index
        routetrain_price = invoice.routetrain.price_per.to_i
        containera_ids = Container.active.where("containernumber ILIKE 'A%'").pluck(:id)
        containerdh_ids = Container.active.where("containernumber ILIKE 'DH%'").pluck(:id)
        routetrainused_ids = 24, 25, 30, 32

        if invoice.routetrain.operator_id == 2 # BKE
          if routetrainused_ids.include? invoice.routetrain_id
            # DRY CONTAINER
            if invoice.container_id.present? && invoice.container_id.to_i != 0
              if invoice.routetrain_id == 30 && (containera_ids.include? invoice.container_id) # DRY 20 FEET
                routetrain_price = 2750000
              elsif invoice.routetrain_id == 30 && (containerdh_ids.include? invoice.container_id) # DRY 20 FEET
                routetrain_price = 2350000
              elsif invoice.routetrain_id == 32 # DRY 20 FEET EMPTY
                routetrain_price = 2800000
              end

            # ISOTANK
            elsif invoice.isotank_id.present? && invoice.isotank_id.to_i != 0
              if invoice.routetrain_id == 24 # ISOTANK 20 FEET
                routetrain_price = 3050000
              elsif invoice.routetrain_id == 25 # ISOTANK 20 FEET EMPTY
                routetrain_price = 2800000
              end
            end
          elsif containera_ids.exclude? invoice.container_id
            routetrain_price = 2250000
          end
        end
        grandtotal += routetrain_price

        inv_desc = invoice.quantity.to_s + ' Rit: ' + (invoice.route.name rescue nil) + ' (' + (invoice.driver.name rescue nil) + ') '
        inv_desc = inv_desc + invoice.description if invoice.description.present?
        inv_coniso = ''
        inv_coniso = invoice.isotank.isotanknumber if invoice.isotank_id.present? && invoice.isotank_id.to_i != 0
        inv_coniso = invoice.container.containernumber if invoice.container_id.present? && invoice.container_id.to_i != 0

        sheet.add_row ['', (i+1).to_s + '.', invoice.date.strftime('%d-%m-%Y'), invoice.id, inv_desc, (invoice.routetrain.name rescue nil), (invoice.vehicle.current_id rescue nil), inv_coniso, invoice.event_id, (invoice.routetrain.container_type rescue nil), (invoice.routetrain.operator.abbr rescue nil), routetrain_price] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, number]
      end

      # Grand Total
      sheet.add_row ['', '', '', '', '', '', '', '', '', '', 'Grand Total', grandtotal] , :height => 20, :style => [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, right_bold, number]
    end

    p.use_autowidth = false
    p.use_shared_strings = true
    send_data p.to_stream.read, type: :xls, filename: "#{title}.xlsx", x_sendfile: true
  end

  def paid
    @where = "trainexpenses-paid"

    @startdate = params[:startdate]
    @startdate = Date.today.strftime('%d-%m-%Y') if @startdate.nil?
    @enddate = params[:enddate]
    @enddate = Date.today.strftime('%d-%m-%Y') if @enddate.nil?

    @operator_id = params[:operator_id]
    @containertype = params[:containertype]

    # @trainexpenses = Invoice.where('invoicetrain = true AND routetrain_id is not null AND routetrain_id !=0  AND date between ? and ? AND invoices.id in (select invoice_id from trainexpenses where deleted = false)', @startdate.to_date, @enddate.to_date).order(:id)
    @trainexpenses = Trainexpense.where('trainexpenses.date between ? and ? and trainexpenses.deleted = false', @startdate.to_date, @enddate.to_date).order(:id)

    if @operator_id.present?
      @trainexpenses = @trainexpenses.joins(:invoice).where('invoices.operator_id = ?', @operator_id)
    end

    if @containertype.present?
      @trainexpenses = @trainexpenses.joins(:routetrain).where('routetrains.container_type = ?', @containertype)
    end

    # render json: @trainexpenses.to_sql
    # return false
  end

  def new
    @where = "trainexpenses"

    @errors = Hash.new
    @invoice_id = params[:invoice_id]
    @invoice = Invoice.find(params[:invoice_id]) rescue nil
    @trainexpense = Trainexpense.new
    respond_to :html
  end

  def edit
    @trainexpense = Trainexpense.find(params[:id])
    respond_to :html
  end

  def create
    inputs = params[:trainexpense]
    inputs[:price_per] = clean_currency(inputs[:price_per])
    inputs[:gst_tax] = clean_currency(inputs[:gst_tax])
    inputs[:gst_percentage] = clean_currency(inputs[:gst_percentage])
    inputs[:misc_total] = clean_currency(inputs[:misc_total])
    inputs[:total] = clean_currency(inputs[:total])
    # render json: inputs
    # return false
    @trainexpense = Trainexpense.new(inputs)
    # @trainexpense.date = Date.today

    if @trainexpense.save
      redirect_to(trainexpenses_url(), :notice => 'Data Biaya Kereta sukses ditambah.')
    else
      redirect_to(new_trainexpense_url(), :notice => 'Data Biaya Kereta gagal ditambah. Data Harus Unik.')
    end
  end

  def update
    inputs = params[:trainexpense]
    @trainexpense = Trainexpense.find(params[:id])

    if @trainexpense.update_attributes(inputs)
      @trainexpense.save
      redirect_to(edit_trainexpense_url(@trainexpense), :notice => 'Data Biaya Kereta sukses disimpan.')
    else
      redirect_to(edit_trainexpense_url(@trainexpense), :notice => 'Data Biaya Kereta gagal diedit. Data Harus Unik.')
    end
  end

  def delete
    @trainexpense = Trainexpense.where('invoice_id = ? AND deleted = false', params[:invoice_id])[0]

    @trainexpense.deleted = true
    @trainexpense.deleteuser_id = current_user.id
    @trainexpense.save
    redirect_to(trainexpenses_url)
  end

  def destroy
    @trainexpense = Trainexpense.find(params[:id])
    @trainexpense.deleted = true
    @trainexpense.save
    redirect_to(trainexpenses_url)
  end

  def enable
    @trainexpense = Trainexpense.find(params[:id])
    @trainexpense.update_attributes(:enabled => true)
    redirect_to(trainexpenses_url)
  end

  def disable
    @trainexpense = Trainexpense.find(params[:id])
    @trainexpense.update_attributes(:enabled => false)
    redirect_to(trainexpenses_url)
  end
end
