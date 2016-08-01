Rails.application.routes.draw do
  root 'users#home'
  get '/admin' => 'admin#admin'
  post 'admin/run'
  post '/submit' => 'users#submit'
  post '/login' => 'users#login'
  get 'confirmation' => 'users#confirmation'
  get 'update' => 'users#update'
  get 'unsubscribe' => 'users#unsubscribe'

  match '/404', to: 'errors#generic', via: :all
  match '/500', to: 'errors#generic', via: :all
  match '/error', to: 'errors#generic', via: :all
end
