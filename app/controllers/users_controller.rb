class UsersController < ApplicationController
	include ApplicationHelper
	layout "application"
  	before_filter :authenticate_user!, :set_section
  	# , :checkrole, :except => [:edit,:update]

  	def checkrole
	    if !current_user.owner
	      redirect_to "/notauthorized" and return false
	    end
	    return true  
	end

  	def mail_domain
  		return "@rdpitrans.com"
  	end

	def set_section
		@section = "settings"	
		@where = "users"
	end

	def after_sign_out_path_for(resource_or_scope)
	    users_path
	end

	def index
		if current_user.owner
			@users = User.where("deleted = false AND username != 'admin'").order(:username)
	    #   @users = User.where.not(:username => 'admin').order(:username)
	    else
	      redirect_to edit_user_path(current_user.id)
	    end
	end

	def new
		@errors = Hash.new 
		@user = User.new

		@roles = Role.find(:all)
	end

	def edit 
		@user = User.find(params[:id])
		if !current_user.owner
			if @user.id != current_user.id
				redirect_to "/notauthorized"
			end
		end
		@process = 'edit'
	end

	def create
		inputs = params[:user]
		
		user_exist = User.where(:username => inputs[:username]).first rescue nil

		if !user_exist
			@user = User.new
			@user.username = inputs[:username]
			@user.adminrole = inputs[:adminrole].to_i == 1 ? true : false
			@user.email = inputs[:username] + mail_domain
			@user.password = inputs[:password]
			@user.staff_id = inputs[:staff_id]
			@user.office_id = inputs[:office_id]

			if @user.save
				if !params["userroles"].nil?
					if @user.userroles.any?
						@user.userroles.delete_all
					end

					params["userroles"].each do |g|
						
						if !g.empty?
							@userrole = Userrole.new
							@userrole.user_id = @user.id
							@userrole.role_id = g
							@userrole.save
						end
					end
				end
			    
				redirect_to(users_path, :notice => 'Data User sukses ditambah')
			else
				render :action => 'new'
			end
		else
			render :action => 'new', :notice => 'Username telah terdaftar.'
		end
		
	end

	def update
		inputs = params[:user]

		@user = User.find(params[:id])
		if current_user.owner
			@user.adminrole = inputs[:adminrole].to_i == 1 ? true : false
			@user.email = inputs[:username] + mail_domain
			@user.staff_id = inputs[:staff_id]
			@user.office_id = inputs[:office_id]
		end
		
		@user.username = inputs[:username]
		@user.password = inputs[:password] if !inputs[:password].blank?

		if @user.save
			if !params["userroles"].nil?
				if @user.userroles.any?
					@user.userroles.delete_all
				end

				params["userroles"].each do |g|
					
					if !g.empty?
						@userrole = Userrole.new
						@userrole.user_id = @user.id
						@userrole.role_id = g
						@userrole.save
					end
				end
			end

			# if current_user.owner or current_user.adminrole
				redirect_to(users_path, :notice => 'Data User sukses disimpan')
			# else
				# redirect_to(edit_user_path(@user), :notice => 'Password sukses diganti')
			# end
		else
			render :action => 'edit'	
		end
	end

	def destroy
		@user = User.find(params[:id])
		@user.deleted = true
		@user.save

		redirect_to(users_path)
	end

end
