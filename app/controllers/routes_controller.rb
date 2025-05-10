class RoutesController < ApplicationController
	include ApplicationHelper
	layout "application"
  before_filter :authenticate_user!, :set_section

  def set_section
    @section = "masters"
    @where = "routes"
    @price_per_types = ["KG", "LITER", "BORONGAN","M3"]
    @transporttypes = ["TRUK", "ISOTANK", "KERETA", "KAPAL (TOL LAUT)"]
    @provinces = [
      "Aceh",
      "Sumatera Utara",
      "Sumatera Barat",
      "Jambi",
      "Bengkulu",
      "Sumatera Selatan",
      "Lampung",
      "Banten",
      "DKI Jakarta",
      "Jawa Barat",
      "Jawa Tengah",
      "DIY (Yogyakarta)",
      "Jawa Timur",
      "Bali",
      "NTB",
      "NTT",
      "Riau"
    ];

    @cities = [
      # Aceh
      "Banda Aceh", "Lhokseumawe", "Langsa", "Meulaboh", "Sigli", "Bireuen",
      # Sumatera Utara
      "Medan", "Binjai", "Pematangsiantar", "Tebing Tinggi", "Sibolga", "Padangsidimpuan",
      # Sumatera Barat
      "Padang", "Bukittinggi", "Payakumbuh", "Pariaman", "Solok", "Sawahlunto",
      # Jambi
      "Jambi", "Sungai Penuh", "Muara Bulian", "Kuala Tungkal",
      # Bengkulu
      "Bengkulu", "Curup", "Manna", "Mukomuko",
      # Sumatera Selatan
      "Palembang", "Lubuklinggau", "Prabumulih", "Pagar Alam", "Lahat",
      # Lampung
      "Bandar Lampung", "Metro", "Kalianda", "Kotabumi", "Liwa",
      # Banten
      "Tangerang", "Serang", "Cilegon", "Rangkasbitung",
      # DKI Jakarta
      "Jakarta Pusat", "Jakarta Selatan", "Jakarta Utara", "Jakarta Barat", "Jakarta Timur",
      # Jawa Barat (Expanded)
      "Bandung", "Bekasi", "Bogor", "Depok", "Cirebon", "Sukabumi", "Tasikmalaya", "Cimahi",
      "Garut", "Purwakarta", "Sumedang", "Indramayu", "Cianjur", "Majalengka", "Subang", "Pangandaran",
      # Jawa Tengah (Expanded)
      "Semarang", "Solo", "Tegal", "Pekalongan", "Magelang", "Salatiga", "Purwokerto", "Cilacap",
      "Kudus", "Jepara", "Pemalang", "Brebes", "Boyolali", "Kebumen", "Blora", "Purwodadi", "Wonosobo","Pati",
      # DIY (Yogyakarta)
      "Yogyakarta", "Sleman", "Bantul", "Wates", "Gunungkidul",
      # Jawa Timur (Expanded)
      "Surabaya", "Malang", "Kediri", "Madiun", "Blitar", "Pasuruan", "Probolinggo", "Banyuwangi", "Jember",
      "Sidoarjo", "Gresik", "Lamongan", "Mojokerto", "Tuban", "Bojonegoro", "Ngawi", "Magetan", "Lumajang",
      "Bondowoso", "Situbondo", "Pacitan", "Trenggalek", "Tulungagung", "Nganjuk", "Ponorogo",
      # Bali
      "Denpasar", "Singaraja", "Tabanan", "Gianyar", "Klungkung",
      # NTB
      "Mataram", "Bima", "Sumbawa Besar", "Praya",
      # NTT
      "Kupang", "Ende", "Maumere", "Waingapu", "Ruteng", "Atambua",
      # Riau
      "Pekanbaru", "Dumai", "Bengkalis", "Tembilahan"
    ]

    @province_cities = {
      "Aceh" => ["Banda Aceh", "Lhokseumawe", "Langsa", "Meulaboh", "Sigli", "Bireuen"],
      "Sumatera Utara" => ["Medan", "Binjai", "Pematangsiantar", "Tebing Tinggi", "Sibolga", "Padangsidimpuan"],
      "Sumatera Barat" => ["Padang", "Bukittinggi", "Payakumbuh", "Pariaman", "Solok", "Sawahlunto"],
      "Jambi" => ["Jambi", "Sungai Penuh", "Muara Bulian", "Kuala Tungkal"],
      "Bengkulu" => ["Bengkulu", "Curup", "Manna", "Mukomuko"],
      "Sumatera Selatan" => ["Palembang", "Lubuklinggau", "Prabumulih", "Pagar Alam", "Lahat"],
      "Lampung" => ["Bandar Lampung", "Metro", "Kalianda", "Kotabumi", "Liwa"],
      "Banten" => ["Tangerang", "Serang", "Cilegon", "Rangkasbitung"],
      "DKI Jakarta" => ["Jakarta Pusat", "Jakarta Selatan", "Jakarta Utara", "Jakarta Barat", "Jakarta Timur"],
      "Jawa Barat" => ["Bandung", "Bekasi", "Bogor", "Depok", "Cirebon", "Sukabumi", "Tasikmalaya", "Cimahi",
      "Garut", "Purwakarta", "Sumedang", "Indramayu", "Cianjur", "Majalengka", "Subang", "Pangandaran"],
      "Jawa Tengah" => ["Semarang", "Solo", "Tegal", "Pekalongan", "Magelang", "Salatiga", "Purwokerto", "Cilacap","Pati"],
      "DIY (Yogyakarta)" => ["Yogyakarta", "Sleman", "Bantul", "Wates", "Gunungkidul"],
      "Jawa Timur" => ["Surabaya", "Malang", "Kediri", "Madiun", "Blitar", "Pasuruan", "Probolinggo", "Banyuwangi", "Jember",
      "Sidoarjo", "Gresik", "Lamongan", "Mojokerto", "Tuban", "Bojonegoro", "Ngawi", "Magetan", "Lumajang",
      "Bondowoso", "Situbondo", "Pacitan", "Trenggalek", "Tulungagung", "Nganjuk", "Ponorogo"],
      "Bali" => ["Denpasar", "Singaraja", "Tabanan", "Gianyar", "Klungkung"],
      "NTB" => ["Mataram", "Bima", "Sumbawa Besar", "Praya"],
      "NTT" => ["Kupang", "Ende", "Maumere", "Waingapu", "Ruteng", "Atambua"],
      "Riau" => ["Pekanbaru", "Dumai", "Bengkalis", "Tembilahan"]
    }
  end

  def managements
    @offices = Office.active.order('id asc')
    # @routes = Route.active.order('name asc')
  end

  def index_api_detailed
    batas = 40
    halaman = params[:page].present? ? params[:page].to_i : 1
    halaman_awal = (halaman > 1) ? (halaman * batas) - batas : 0
    # halaman_awal = halaman_awal + 1
    additional_query = ""
    if params[:query].present?
      additional_query += " and name ~* '.*#{params[:query]}.*'"
    end
    if params[:customer_id].present? && params[:customer_id] != "all"
      additional_query += " and customer_id = '#{params[:customer_id]}"
    end
    if params[:load_province].present? && params[:load_province] != "all"
      additional_query += " and load_province = '#{params[:load_province]}'"
    end
    if params[:unload_province].present? && params[:unload_province] != "all"
      additional_query += " and unload_province = '#{params[:unload_province]}'"
    end

    @office_id = params[:office_id]
    if @office_id.present? and @office_id != "all"
      all_data = Route.active.where("office_id = ?#{additional_query}", @office_id).select(:id).count()
      @routes = Route.active.where("office_id = ?#{additional_query}", @office_id).limit(batas).offset(halaman_awal).order("name asc")
    else
      all_data = Route.where("deleted = false#{additional_query}").select(:id).count()
      @routes = Route.where("deleted = false#{additional_query}").limit(batas).offset(halaman_awal).order("name asc")
    end

    @total_page = (all_data.to_f / batas.to_f).ceil

    render partial: "table_detailed"
    # render json: @routes.to_sql
  end

  def index
    @offices = Office.active.order('id asc')
  end

  def index_api
    batas = 40
    halaman = params[:page].present? ? params[:page].to_i : 1
    halaman_awal = (halaman > 1) ? (halaman * batas) - batas : 0
    # halaman_awal = halaman_awal + 1
    additional_query = ""
    if params[:query].present?
      additional_query += " and name ~* '.*#{params[:query]}.*'"
    end
    if params[:customer_id].present? && params[:customer_id] != "all"
      additional_query += " and customer_id = #{params[:customer_id]}"
    end

    @office_id = params[:office_id]
    if @office_id.present? and @office_id != "all"
      all_data = Route.active.where("office_id = ?#{additional_query}", @office_id).select(:id).count()
      @routes = Route.active.where("office_id = ?#{additional_query}", @office_id).limit(batas).offset(halaman_awal).order("name asc")
    else
      all_data = Route.where("deleted = false#{additional_query}").select(:id).count()
      @routes = Route.where("deleted = false#{additional_query}").limit(batas).offset(halaman_awal).order("name asc")
    end



    @total_page = (all_data.to_f / batas.to_f).ceil

    render partial: "table"
    # render json: @routes.to_sql
  end

  def addnew
    @route = Route.new
    respond_to :html
  end

  def new
    @route = Route.new
    if params[:format].present?
      @customer = Customer.find(params[:format])
      @route.customer_id = @customer.id
    end
    @route.ferry_fee = @route.ferry_fee.to_i
    @route.tol_fee = @route.tol_fee.to_i
    @route.tol_fee_trailer = @route.tol_fee_trailer.to_i
    @route.bonus = @route.bonus.to_i
    @route.enabled = true
    # respond_to :html
  end

  def edit
    @route = Route.find(params[:id])
    @customer = Customer.find(@route.customer_id)
    @route.ferry_fee = @route.ferry_fee.to_i
    @route.tol_fee = @route.tol_fee.to_i
    @route.tol_fee_trailer = @route.tol_fee_trailer.to_i
    @route.bonus = @route.bonus.to_i

    route_allowance = @route.allowances.where("driver_trip > money(0) or helper_trip > money(0) or gas_trip > (0) or misc_allowance > money(0)").first rescue nil
    if @route.distance.nil? ||@route.distance == 0
      gas_trip = (route_allowance.try(:gas_trip).to_f || 0.0)
      if @route.name.downcase.include?('kosongan')
        @route.distance = (gas_trip * 3).round().to_i
      else
        @route.distance = (gas_trip * 2.3).round().to_i 
      end
    end

    @routeloc = Routelocation.where("route_id = ?", params[:id]).order("id DESC").limit(1)

		if @routeloc.first.nil?
			@routelocation = Routelocation.new
			@routelocation.route_id = @route.id
			@routelocation.customer_id = @customer.id
			@routelocation.save
		else
			@routelocation = Routelocation.where("route_id = ?", params[:id]).order("id DESC").find(@routeloc.first.id)
		end

    @vehiclegroups = Vehiclegroup.all
    @vehiclegroups.each do |g|
      if g.allowances.where(:route_id => @route.id).first.nil?
        allowance = Allowance.new
        allowance.route_id = @route.id
        allowance.vehiclegroup_id = g.id
        allowance.save
      end
    end
  end

  def create
    inputs = params[:route]
    @route = Route.new(inputs)
    @route.enabled = true
    @route.user_id = current_user.id

    if checkrole 'Marketing, Admin Marketing'

      @route.price_per = inputs[:price_per].delete('.').gsub(",",".") || 0

    else

      @route.price_per = 0

    end

    if @route.save
      redirect_to(edit_route_url(@route), :notice => 'Data Jurusan sukses di tambah.')
    else
      to_flash(@route)
      render :action => "new"
    end
  end

  def update
    inputs = params[:route]
    @route = Route.find(params[:id])
    oldcustomer = @route.customer_id
    # needupdate = false

    #if @route.price_per.to_i != inputs[:price_per].to_i
    #  needupdate = true
    #end

    if @route.update_attributes(inputs)


      if checkrole 'Marketing, Admin Marketing'

        @route.price_per = inputs[:price_per].delete('.').gsub(",",".") || 0

      end

      @route.save

      if oldcustomer != @route.customer_id
        invoices = Invoice.where(:customer_id => oldcustomer, :route_id => @route.id)
        if invoices.any?
          invoices.each do |invoice|
            invoice.customer_id = @route.customer_id
            invoice.save

            invoice.taxinvoiceitems.where(:taxinvoice_id => nil).each do |taxinvoiceitem|
              taxinvoiceitem.customer_id = @route.customer_id
              taxinvoiceitem.save
            end
          end
        end
      end

      #if needupdate == true
      #  invoices = Invoice.where(:route_id => @route.id, :deleted => false)
      #
      #  if invoices.any?
      #    invoices.each do |invoice|
      #       invoice.price_per = @route.price_per
      #       invoice.save
      #     end
      #   end
      # end

      redirect_to(edit_route_url(@route, :operational => true), :notice => 'Data Jurusan sukses disimpan.')
    else
      to_flash(@route)
      render :action => "edit"
    end
  end

  def destroy
    @route = Route.find(params[:id])
    customer_id = @route.customer_id
    @route.destroy
    redirect_to edit_customer_url(customer_id)+'/#2'
  end

  def enable
    @route = Route.find(params[:id])
    @route.update_attributes(:enabled => true)
    redirect_to (routes_url)
  end

  def disable
    @route = Route.find(params[:id])
    @route.update_attributes(:enabled => false)
    redirect_to (routes_url)
  end

  def approve
    @route = Route.find(params[:id])
    @route.approved = true
    @route.approved_at = Time.new.strftime("%Y-%m-%d")
    @route.approved_by = current_user.id
    @route.save
    redirect_to(edit_route_path(params['id']), :notice => 'Data Jurusan sukses di-approve.')
  end

end
