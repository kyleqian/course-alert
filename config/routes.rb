Rails.application.routes.draw do
  root 'users#home'
  get '/admin' => 'admin#admin'
  post 'admin/run'
  post '/submit' => 'users#submit'
  post '/login' => 'users#login'
  get 'confirmation' => 'users#confirmation'
  get 'update' => 'users#update'
  get 'unsubscribe' => 'users#unsubscribe'
end
