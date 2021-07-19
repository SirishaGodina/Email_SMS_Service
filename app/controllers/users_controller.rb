class UsersController < ApplicationController
  require 'httparty'
  require 'json'
  #before_action :authorize_request, except: :create
  before_action :find_user, except: %i[create index search_user verify_passcodes]

  # GET /users
  
  def index
    @users = User.all    
    render json: @users, status: :ok
  end

  # GET /users/{username}
  def show
    render json: @user, status: :ok
  end

  # POST /users
  def create
    @user = User.new(user_params)
     
     token = JsonWebToken.encode(user_id: @user.id)
      time = Time.now + 24.hours.to_i       
        
    if @user.save 
          @user.update_column(:token, token)
       if send_passcode
          #render(json: {message: 'Sent passccode'}, status: :ok)
          render json: { token: token, exp: time.strftime("%m-%d-%Y %H:%M"),
                     username: @user.username, message: 'User created Sent passccode' }, status: :ok
       else
          render(json: {error: 'failed to send passcode'}, status: :unauthorized)
       end           
         
      #render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end#def

  def verify
  
  @user = User.find_by_email(params[:email])
  otp = params[:otp]
  session_key = @user.session_key
  if @user 
    response = verify_passcode(session_key, otp)
    render json: response['Details'] 
  else
    render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
  end
  end#def

  def verify_passcode(session_key, passcode)
    TwoFactor.verify_passcode(session_key, passcode)
  end

  def send_passcode
    @user = User.find_by_email(params[:email])
    response = TwoFactor.send_passcode(@user.phone_no)
    @otp = response['OTP'] 
    if (response['Status'].downcase == 'success')
      @user.update_column(:session_key, response['Details'])      
    end
    UserMailer.welcome_email(@otp, @user).deliver_now
  end
 
  # PUT /users/{username}
  def update
    unless @user.update(user_params)
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  # DELETE /users/{username}
  def destroy
    @user.destroy
  end
  
  def search_user
    
    @users = User.where("name = ? OR username = ? OR email = ? OR phone_no = ?",
      params[:name], params[:username], params[:email], params[:phone_no])   
    render json: @users, status: :created
  end

  def retry
        @user = User.find_by_email(params[:email])
        response = TwoFactor.send_passcode(@user.phone_no)
        if (response['Status'].downcase == 'success')
        @user.update_column(:session_key, response['Details']) 
        @otp = response['OTP'] 
        UserMailer.welcome_email(@otp, @user).deliver_now     
        end        
        render json: 'OTP has been resent'
           
  end  

  def send_mail
      
    UserMailer.welcome_email(params[:mail]).deliver_now
  end

  def send_sms
    TwoFactor.send_passcode(params[:phone_no])
        
  end

  private

  def find_user
      
    @user = User.where(username: params[:_username] )
    rescue ActiveRecord::RecordNotFound
      render json: { errors: 'User not found' }, status: :not_found
  end

  def user_params
    params.permit(
      :name, :username, :email, :password, :password_confirmation, :phone_no, :token, :mail
    )
  end

 end
