Rails.application.routes.draw do


  get 'setup', controller: :pages, action: :redirect
  get 'callback', controller: :pages, action: :callback
  get 'analytics', controller: :pages, action: :analytics
  get 'get_data', controller: :pages, action: :get_data, as: :get_data

  post :subscribe, controller: :subscriptions, action: :subscribe
  post :check_api, controller: :subscriptions, action: :check_api
  post :notify_with_api, controller: :subscriptions, action: :notify_with_api

  post :notify_with_webhook, controller: :subscriptions, action: :notify_with_webhook

  root controller: :pages, action: :index

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
