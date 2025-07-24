class SummariesController  < ApplicationController
    include ApplicationHelper
    include ActionView::Helpers::NumberHelper
    layout "application", :except => []
    before_filter :authenticate_user!, :set_section

    def set_section
    end

    def doubtful_ar_reports
        role = cek_roles 'Admin Penagihan'
 
        if role
            @startdate = params[:startdate]
            @startdate = Date.today.at_beginning_of_month.strftime('%d-%m-%Y') if @startdate.nil?
            @enddate = params[:enddate]
            @enddate = (Date.today.at_beginning_of_month.next_month - 1.day).strftime('%d-%m-%Y') if @enddate.nil?

            @taxinvoices = Taxinvoice.active.where("doubtful_ar = true AND (date >= ? and date < ?)", @startdate.to_date, @enddate.to_date + 1).order(:date)

            @section = "taxinvoices"
            @where = "doubtful_ar_reports"
            @pagetitle = 'Laporan Piutang Bermasalah'
            render "doubtful_ar_reports"
        else
            redirect_to root_path()
        end

    end

end