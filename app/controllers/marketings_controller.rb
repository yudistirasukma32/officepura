class MarketingsController < ApplicationController
	include ApplicationHelper
	layout "application"
	before_filter :authenticate_user!, :set_section

	respond_to :html
 
	def set_section
		@section = "marketings"
		@where = "marketings"
	end

	def index

		@startdate = params[:startdate]
		@startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
		@enddate = params[:enddate]
		@enddate = (Date.today).strftime('%d-%m-%Y') if @enddate.nil?
		
		@new_customers = Customer.active.unverified

		@claimmemos = Claimmemo.active.where('approved = false or approved_by_gm = false')
  
		@confirmed_quotation = Quotationgroup.active.pluck(:id)
		@quotation = Quotation.active.where('quotationgroup_id in (?)', @confirmed_quotation).pluck(:id)
		@allowances = Allowance.active.where('driver_trip = money(0)').pluck(:route_id)
		@new_routes = Route.active.where('quotation_id in (?) and id in (?)', @quotation, @allowances)
  
		# @quotationgroups = Quotationgroup.active.where('date >= ?', Date.new(2025, 1, 1)).reorder('date DESC')
		@quotationgroups = Quotationgroup.active.where('date >= ?', Date.current.beginning_of_month).reorder('date DESC')

		@quotationgroups_draft = @quotationgroups.where('reviewed = false AND confirmed = false')
		@quotationgroups_reviewed = @quotationgroups.where('reviewed = true AND confirmed = false')
		@quotationgroups_confirmed = @quotationgroups.where('confirmed = true AND is_sent = false')
		@quotationgroups_sent = @quotationgroups.where('is_sent = true AND customer_approved = false')
		@quotationgroups_approved = @quotationgroups.where('customer_approved = true')

		@default_month = Date.today;

		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)
	
		# exclude contract cust
		# contract_customer_id = 112
		contract_customer_id = 379 #mayora

		# @stat_indra = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 14)
		# @stat_lilis = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 69)
		# @stat_finca = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 93)
		# @stat_anin = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 112)

		@stat_indra = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 14).order(:start_date)
		@stat_lilis = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 69).order(:start_date)
		@stat_finca = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 93).order(:start_date)
		@stat_anin = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 112).order(:start_date)
		@stat_stefano = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 125).order(:start_date)

		user_ids = [14, 69, 93, 112, 125]
		@events_by_user = {}

		user_ids.each do |user_id|
		total_estimation = 0

		@events = Event.active
			.where("customer_id != ? AND start_date BETWEEN ? AND ?", contract_customer_id, @startdate.to_date, @enddate.to_date)
			.where(user_id: user_id).includes(:route).map do |event|
				route = event.route
				price_per = route.price_per.to_i rescue 0
				price_per_type = route.price_per_type rescue 'KG'
				quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0
		
				quantity = event.qty.to_i rescue 0
				event_price_per_type = event.price_per_type rescue 'KG'
				event_tonage = event.estimated_tonage.to_i rescue 0
		
				if price_per >= offset
				estimation = quantity * price_per
				elsif customer_35.include? event.customer_id
				estimation = quantity * 20000 * price_per
				else
				estimation = quantity * event_tonage *  price_per
				end
		
				total_estimation += estimation
			end

			@events_by_user["omzet_#{user_id}"] = total_estimation

		end
		
		# render json: @events_by_user
		# return false
	end

	def filtered

		@startdate = params[:startdate]
		@startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
		@enddate = params[:enddate]
		@enddate = (Date.today).strftime('%d-%m-%Y') if @enddate.nil?

		@new_customers = Customer.active.unverified

		@claimmemos = Claimmemo.active.where('approved = false or approved_by_gm = false')
  
		@confirmed_quotation = Quotationgroup.active.pluck(:id)
		@quotation = Quotation.active.where('quotationgroup_id in (?)', @confirmed_quotation).pluck(:id)
		@allowances = Allowance.active.where('driver_trip = money(0)').pluck(:route_id)
		@new_routes = Route.active.where('quotation_id in (?) and id in (?)', @quotation, @allowances)
  
		# @quotationgroups = Quotationgroup.active.where('date >= ?', Date.new(2025, 1, 1)).reorder('date DESC')
		@quotationgroups = Quotationgroup.active.where('date >= ?', Date.current.beginning_of_month).reorder('date DESC')

		@quotationgroups_draft = @quotationgroups.where('reviewed = false AND confirmed = false')
		@quotationgroups_reviewed = @quotationgroups.where('reviewed = true AND confirmed = false')
		@quotationgroups_confirmed = @quotationgroups.where('confirmed = true AND is_sent = false')
		@quotationgroups_sent = @quotationgroups.where('is_sent = true AND customer_approved = false')
		@quotationgroups_approved = @quotationgroups.where('customer_approved = true')

		@default_month = Date.today;

		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)
	
		# exclude contract cust
		#contract_customer_id = 112
		contract_customer_id = 379 #mayora

		if @startdate.nil? && @enddate.nil?
			@stat_indra = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 14)
			@stat_lilis = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 69)
			@stat_finca = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 93)
			@stat_anin = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 112)
			@stat_stefano = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ? AND user_id = ?", contract_customer_id, @default_month.beginning_of_month, 125)
		else
			@stat_indra = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 14).order(:start_date)
			@stat_lilis = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 69).order(:start_date)
			@stat_finca = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 93).order(:start_date)
			@stat_anin = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 112).order(:start_date)
			@stat_stefano = Event.active.where("start_date BETWEEN ? AND ? AND customer_id != ? AND user_id = ?", @startdate.to_date, @enddate.to_date, contract_customer_id, 125).order(:start_date)
		end

		user_ids = [14, 69, 93, 112, 125]
		@events_by_user = {}

		user_ids.each do |user_id|
		total_estimation = 0

		if @startdate.nil? && @enddate.nil?

			@events = Event.active
			.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ?", contract_customer_id, @default_month.beginning_of_month)
		
		else

			@events = Event.active
			.where("customer_id != ? AND start_date BETWEEN ? AND ?", contract_customer_id, @startdate.to_date, @enddate.to_date)

		end
		
			@events.where(user_id: user_id).includes(:route).map do |event|
				route = event.route
				price_per = route.price_per.to_i rescue 0
				price_per_type = route.price_per_type rescue 'KG'
				quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0
		
				quantity = event.qty.to_i rescue 0
				event_price_per_type = event.price_per_type rescue 'KG'
				event_tonage = event.estimated_tonage.to_i rescue 0
		
				if price_per >= offset
				estimation = quantity * price_per
				elsif customer_35.include? event.customer_id
				estimation = quantity * 20000 * price_per
				else
				estimation = quantity * event_tonage *  price_per
				end
		
				total_estimation += estimation
			end

			@events_by_user["omzet_#{user_id}"] = total_estimation

		end
		
		# render json: @events_by_user
		# return false
	end

	def getomzetdata

		month_text = []
		event_count = []
		event_estimation = []

		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)
	
		# exclude contract cust
		#contract_customer_id = 112
		contract_customer_id = 379 #mayora

		@months = (0..5).map { |i| Date.today << i }.reverse.each do |mo|

		  month_text << mo.strftime("%b %Y")
		  @events = Event.active.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ?", contract_customer_id, mo.beginning_of_month)
		  event_count << @events.count

		  total_estimation = 0

			@events = @events.includes(:route).map do |event|
				route = event.route
				price_per = route.price_per.to_i rescue 0
				price_per_type = route.price_per_type rescue 'KG'
				quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0
 
				quantity = event.qty.to_i rescue 0
				event_price_per_type = event.price_per_type rescue 'KG'
				event_tonage = event.estimated_tonage.to_i rescue 0
		
				if price_per >= offset
				estimation = quantity * price_per
				elsif customer_35.include? event.customer_id
				estimation = quantity * 20000 * price_per
				else
				estimation = quantity * event_tonage *  price_per
				end
		
				total_estimation += estimation
			end

			event_estimation << total_estimation
		end
		
		render json: { success: true, month_text: month_text, event_count: event_count, omzet: event_estimation }

	end

	def getomzetdatamarketing
		month_text = []
		offset = Setting.find_by_name('Offset Estimasi').to_i rescue 200000
		customer_35 = Customer.active.where("name ~* '.*Molindo.*' or name ~* '.*Aman jaya.*' or name ~* '.*Acidatama.*'").pluck(:id)
	
		# exclude contract cust
		# contract_customer_id = 112
		contract_customer_id = 379 #mayora

		#marketings
		user_ids = [14, 69, 93, 112, 125]
		@events_by_user = {}
		
		user_ids.each do |user_id|
		  @omzet_per_month = []
		
		  # Manually define the last 3 months
		#   @months = [
		# 	Date.new(2025, 1, 1),
		# 	Date.new(2025, 2, 1),
		# 	Date.new(2025, 3, 1)
		#   ]

		  @months = (0..2).map { |i| Date.today.prev_month(i).beginning_of_month }.reverse
		
		  @months.each do |mo|
			month_text << mo.strftime("%b %Y")
			total_estimation = 0
		
			@events = Event.active
			.where("customer_id != ? AND DATE_TRUNC('month', start_date) = ?", contract_customer_id, mo.beginning_of_month)
			@events.where(user_id: user_id).includes(:route).map do |event|
				route = event.route
				price_per = route.price_per.to_i rescue 0
				price_per_type = route.price_per_type rescue 'KG'
				quantity = event.invoicetrain ? (event.qty.to_i * 2) : event.qty.to_i rescue 0
		
				quantity = event.qty.to_i rescue 0
				event_price_per_type = event.price_per_type rescue 'KG'
				event_tonage = event.estimated_tonage.to_i rescue 0
		
				if price_per >= offset
				estimation = quantity * price_per
				elsif customer_35.include? event.customer_id
				estimation = quantity * 20000 * price_per
				else
				estimation = quantity * event_tonage *  price_per
				end
		
				total_estimation += estimation
			end
		
			@omzet_per_month << total_estimation / 1000000
		  end
		
		  @events_by_user["omzet_#{user_id}"] = @omzet_per_month
		end

		# this_months = @events_by_user.map(&:last)
		this_months = @events_by_user.values.map(&:last)
		total = this_months.sum
		
		render json: { success: true, month_text: month_text, users: @events_by_user, this_month: this_months, total: total }

	end

end