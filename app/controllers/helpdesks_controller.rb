class HelpdesksController < ApplicationController
#	include ApplicationHelper
	layout "application"
	before_filter :set_section
	protect_from_forgery except: [:create, :updateticket]
	
  def set_section
    @section = "helpdesk"
		@where = "helpdesk"
  end	
	
  def index

		require "uri"
		require "net/http"
		require "openssl"
		require 'json'
		
		if current_user.owner
			
			@startdate = params[:start]
			@enddate = params[:end]
			@periode = ''
			
			if @startdate && @enddate
				
				@periode = 'Periode: ' + @startdate + ' s/d ' + @enddate
		
				url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/get/company?code=rdpi&start="+@startdate+"&end="+@enddate)
				
			else
				
				@month = Date.today
				
				@periode = 'Periode: ' + @month.strftime("%B") + ' ' + Date.today.year.to_s
				#live
				url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/get/company?code=rdpi")
				
			end
			
#			url = URI("http://localhost/mdt-helpdesk/public/api/v1/ticket/get/company?code=rdpi")
			
		else
			
			@username = current_user.username
			@startdate = params[:start]
			@enddate = params[:end]
			@periode = ''	
			
			if @startdate && @enddate
			
				@periode = 'Periode: ' + @startdate + ' s/d ' + @enddate
				url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/get/company?code=rdpi&name="+@username+"&start="+@startdate+"&end="+@enddate)
				
			else
				
			@month = Date.today

			@periode = 'Periode: ' + @month.strftime("%B") + ' ' + Date.today.year.to_s
			
			#live
			url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/get/user?code=rdpi&name="+@username)
			
#			url = URI("http://localhost/mdt-helpdesk/public/api/v1/ticket/get/user?code=rdpi&name="+@username)
			
			end	
			
		end

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
		@response = response.read_body
		
		if JSON(@response)['status'] == 404
			
		@ticketsEmpty = TRUE

		else	
			
		@tickets = JSON(@response)['tickets']
			
		end
		
  end
	
	def edit
		
		require "uri"
		require "net/http"
		require "openssl"
		require 'json'
		
		@process = 'edit'
		
		@id = params[:id]
		
		#live
		url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/detail?id="+@id)
		
#		url = URI("http://localhost/mdt-helpdesk/public/api/v1/ticket/detail?id="+@id)

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
		@response = response.read_body
		
		@ticket = JSON(@response)['value']
		
	end
	
  def show
		
		require "uri"
		require "net/http"
		require "openssl"
		require 'json'
		
		@process = 'show'
		
		@id = params[:id]
		
		#live
		url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/detail?id="+@id)
		
#		url = URI("http://localhost/mdt-helpdesk/public/api/v1/ticket/detail?id="+@id)

		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Get.new(url.request_uri)

		response = http.request(request)
		@response = response.read_body
		
		@ticket = JSON(@response)['value']
 
  end
	
  def new
		
		@process = 'new'
 
  end
	
	def create
		
		require "uri"
		require "net/http"
		require "openssl"
		require 'json'
		
		inputs = params[:helpdesk]
		
		#live
		url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/create")

#		url = URI("http://localhost/mdt-helpdesk/public/api/v1/ticket/create")

		http = Net::HTTP.new(url.host, url.port);
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE	
		request = Net::HTTP::Post.new(url.request_uri)
		request["Cookie"] = "PHPSESSID=c2c79fd2bad030f33d363218699b8a72"
		form_data = [['subject', inputs["subject"]],['companyCode', 'rdpi'],['name', inputs["username"]],['description', inputs["description"]],['priority', 'normal']]
		
		request.set_form form_data, 'multipart/form-data'
		response = http.request(request)
#		puts response.read_body
		
		redirect_to(helpdesks_url, :notice => 'Data Ticket berhasil dibuat')
		
	end

  def updateticket
		
		require "uri"
		require "net/http"
		require "openssl"
		require 'json'
		
		inputs = params[:helpdesk]
		id = inputs["id"]
		closed = inputs["closed"]
		remarks = inputs["remarks"]
		
		status = 'FALSE'
		
		if closed == 'TRUE'
			status = 'TRUE'
		end
		
		#live
		url = URI("https://api-helpdesk.mydevteam.id/api/v1/ticket/update")		
		
#		url = URI("http://localhost/mdt-helpdesk/public/api/v1/ticket/update")

		http = Net::HTTP.new(url.host, url.port);
		http.use_ssl = true
		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
		request = Net::HTTP::Post.new(url.request_uri)
		request["Cookie"] = "PHPSESSID=c2c79fd2bad030f33d363218699b8a72"
		form_data = [['id', id],['closed', status],['remarks', remarks]]
		
		request.set_form form_data, 'multipart/form-data'
		@response = http.request(request)
#		puts response.read_body
 
		redirect_to(helpdesks_url, :notice => 'Data Ticket berhasil diperbarui')
		
  end

end
