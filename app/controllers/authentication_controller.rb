class AuthenticationController < ApplicationController
  
  require 'httparty'
  require 'timeout'
  before_action :authorize_request, except: :login

  # POST /auth/login
  
  def login
    @user = User.find_by_email(params[:email])
    if @user&&authenticate       
      
      render json: 'Logged in successfully'
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  def authenticate
    password = User.find_by_email(params[:email]).password
    if (params[:password] == password)
      return true
    end
  end

  def log_out
  end

  private

  def login_params
    params.permit(:email, :password, :token)
  end
end
