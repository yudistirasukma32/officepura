class TaxinvoicesapiController < ApplicationController
  include ActionView::Helpers::NumberHelper
  def index
    @taxinvoices = Taxinvoice.where("sentdate is not null AND paiddate is null").where("DATE_PART('day', (sentdate + interval '7' day) - current_date) = 0").order(:long_id)

    # @month = params[:month]
    # @month = "%02d" % Date.today.month.to_s if @month.nil?
    # @year = params[:year]
    # @year = Date.today.year if @year.nil?
    # @taxinvoices = Taxinvoice.where("to_char(date, 'MM-YYYY') = ? AND sentdate is not null AND paiddate is null", "#{@month}-#{@year}").order(:long_id)

    @taxinvoices = @taxinvoices.map do |u|

      if u.sentdate
          duedate =  u.sentdate + u.customer.terms_of_payment_in_days.to_i.days
          datediff = ((u.sentdate + u.customer.terms_of_payment_in_days.to_i.days) - Date.today).to_i 
      else
          duedate =  u.date + u.customer.terms_of_payment_in_days.to_i.days
          datediff = ((u.date + u.customer.terms_of_payment_in_days.to_i.days) - Date.today).to_i 
      end

      total = "Rp " + to_currency_bank(u.total)
      created_date =  u.created_at.strftime('%Y-%m-%d')

      if datediff = 7
        
      { 
        :long_id => u.long_id,
        :total => total,
        :created_date => created_date,
        :date   => u.date,
        :sentdate   => u.sentdate,
        :duedate => duedate,
        :paiddate => u.paiddate,
        :customer => u.customer.name,
        :customer_email => u.customer.email,
        :customer_email_alt => u.customer.email_alt,
        :datediff => datediff
      }

      end

    end

    if @taxinvoices.count > 0

      render json: { status: 200, message: ("Taxinvoices Found"), data: @taxinvoices }

    else

      render json: { status: 404, message: ("Taxinvoices Not Found"), data: {}}

    end

  end

  def send_email

    # @name = 'Test'
    # @email = 'yudistira@mydevteam.com.au'
    # @finance_mail = 'finance@rdpitrans.com'
    
    # @taxinvoice = Taxinvoice.find(params[:taxinvoice_id])
    
    # if @taxinvoice.present? 
        
    # @long_id =  @taxinvoice.long_id
      
    # @total = to_currency(@taxinvoice.total)
    # @customer = @taxinvoice.customer.name
    # @sent_date = @taxinvoice.sentdate
    # inv_subject = "Invoice Tagihan "+@long_id+" "+@customer
        
    # if @sent_date.nil?
    #     @sent_date = Date.today.strftime('%d-%m-%Y')
    # end
        
    # html = render_to_string partial: 'email_template/taxinvoice_sent'

    # require 'uri'
    # require 'json'
    # require 'net/http'

    # url = URI('https://api.sendinblue.com/v3/smtp/email')

    # https = Net::HTTP.new(url.host, url.port)
    # https.use_ssl = true

    # request = Net::HTTP::Post.new(url)
    # request['accept'] = 'application/json'
    # request['content-type'] = 'application/json'
    # request['api-key'] = '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'
    # request.body = JSON.dump({
    #     'to': [
    #         {
    #         'email': @email,
    #         'name': @customer
    #         },
    #     ],
    #     'sender': {
    #         'email': 'no-reply@rdpitrans.com',
    #         'name': 'RDPI Trans'
    #     },
    #     'subject': inv_subject,
    #     'htmlContent': html,
    #     'headers': { 
    #         'charset': 'iso-8859-1'
    #     }
    # })

    # response = https.request(request)
        
    # render json: { status: 200, message: "Success", response: response }
        
    #end

  end

end
