Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users, param: :_username
  post '/auth/login', to: 'authentication#login'
  post '/auth/verify_otp', to: 'authentication#verify_otp'
  get '/*a', to: 'application#not_found'
end