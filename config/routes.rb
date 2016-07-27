Rails.application.routes.draw do
  root 'user#home'
  get '/admin' => 'admin#admin'
  post 'admin/run'
end
