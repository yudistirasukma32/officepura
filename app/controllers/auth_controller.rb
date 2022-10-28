class AuthController < ApplicationController
	def login
		vars = request.query_parameters
		username = vars['username']
		password = vars['password']

		user = User.where(username: username).first rescue nil
        
		if user.present?
			if !user.valid_password?(password)
				render json: { status: 400, message: "Login Failed, Incorrect Password", data: {} }	
			elsif user.valid_password?(password)
                if !user.deleted || user.username == 'admin'
				    render json: { status: 200, message: "Login Success", data: user }
                else
                    render json: { status: 400, message: "Account Inactive", data: {} }
                end
			end
			# render json: { status: 400, message: "Login Failed, Account not found", data: {} }
		return false
		end
		render json: { status: 400, message: "Login Failed, Account not found", data: {} }
	end
end
