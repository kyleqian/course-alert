Rails.application.routes.draw do
  root 'users#home'
  get '/admin' => 'admin#admin'
  get 'users/login' => 'users#login'
  post 'admin/run'
  post 'users/submit'
end
