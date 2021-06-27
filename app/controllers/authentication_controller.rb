class AuthenticationController < ApplicationController
  
  require 'httparty'
  before_action :authorize_request, except: :login

  # POST /auth/login
  TWO_FACTOR_API_KEY = 'f6d58176-d4f0-11eb-8089-0200cd936042'
  def login
    @user = User.find_by_email(params[:email])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i
      @otp = SecureRandom.random_number(10**6).to_s.rjust(6, '0')
      session[:otp] = @otp      
      #UserMailer.welcome_email(@otp).deliver_now 
      UserMailer.welcome_email(@otp, @user).deliver_now    
      response = HTTParty.get("https://2factor.in/API/V1/#{TWO_FACTOR_API_KEY}/SMS/#{@user.phone_no}/AUTOGEN")
      puts response.body if response.code == 200
      render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     username: @user.username }, status: :ok 
       #render json: { token: @user.token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     #username: @user.username }, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end
  def send_passcode
    @user = User.find_by_email(params[:email])
    response = TwoFactor.send_passcode(@user.phone_no)
    if response['Status'].downcase == 'success'
      update_column(:session_key, response['Details'])
      true
    end
  end

  def verify_otp
    if (session[:otp] == params[:otp])
      render json: 'OTP Verified'
    
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end
  private

  def login_params
    params.permit(:email, :password, :token, :otp)
  end
end
