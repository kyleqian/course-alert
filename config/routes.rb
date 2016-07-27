Rails.application.routes.draw do
  root 'user#home'
  get '/admin' => 'admin#admin'
end
