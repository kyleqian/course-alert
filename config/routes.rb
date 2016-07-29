Rails.application.routes.draw do
  root 'users#home'
  get '/admin' => 'admin#admin'
  post 'admin/run'
  post 'users/submit'
  post 'users/login'
  get 'users/confirmation'
end
