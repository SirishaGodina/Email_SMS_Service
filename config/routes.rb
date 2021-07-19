Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, param: :_username
  post '/users/search_user', to: 'users#search_user'
  post '/users/send_sms', to: 'users#send_sms'
  post '/users/send_mail', to: 'users#send_mail'
  post '/users/verify_passcode', to: 'users#verify_passcode'
  post '/users/verify', to: 'users#verify'
  post '/users/retry', to:'users#retry'
  post '/auth/login', to: 'authentication#login'
  post '/auth/verify_otp', to: 'authentication#verify_otp'
  post '/auth/verify_otp1', to: 'authentication#verify_otp1'
  delete '/auth/log_out', to: 'authentication#log_out'
  get '/*a', to: 'application#not_found'
end
