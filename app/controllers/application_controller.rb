class ApplicationController < ActionController::Base

  include PublicActivity::StoreController

	include ApplicationHelper
	
	protect_from_forgery

	helper_method :active_section, :active_node

	def home
		if user_signed_in?
			redirect_to "/dashboard"
		else
			redirect_to "/user/login"
		end
	end

	def login
		# @errors = Hash.new

		# if request.post?
		# 	@formdata = params[:user]
		# 	@errors["username"] = "Akun tidak boleh kosong." if @formdata["username"].empty?

		# 	if @errors.length==0
		# 		flag = false
		# 		if @formdata["username"] == "master@mydevteam.com.au" and @formdata["password"] == "nov2011"
		# 			flag = true
		# 		elsif @formdata["username"] == "admin" and @formdata["password"] == "rajawali123"
		# 			flag = true
		# 		else
		# 			flag = true if User.where(:username => @formdata["username"], :password => @formdata["password"], :deleted => false, :enabled => true).first
		# 		end

		# 		if flag 
		# 			session[:username] = @formdata["username"]

		# 			if @formdata["username"] == "admin" or @formdata["username"] == "master@mydevteam.com.au"
		# 				session[:adminrole] = true
		# 			else
		# 				@user = User.where(:username => @formdata["username"]).first
		# 				if !@user.nil?
		# 					@user.last_login = DateTime.now.strftime('%d-%m-%Y %H:%M:%S')
		# 					@user.count_login = @user.count_login.to_i + 1

		# 					session[:adminrole] = @user.adminrole

		# 					@user.save
		# 				end
		# 			end

		# 			redirect_to root_url and return					
		# 		else
		# 			flash[:notice] = "Login Anda salah. Mohon login kembali dengan akun yang benar."
		# 		end
		# 	end
		# end
		# @where = "login"
	end

	def logout
		reset_session
		redirect_to root_url
	end

	def notauthorized
	end

  protected
    # Root class and active menu items
    def active_section
      @active_section ||= params[:controller]
    end

    def active_node
      @active_node ||= params[:action]
    end	
end
