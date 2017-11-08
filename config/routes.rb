Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  patch 'set_nick', to: 'tool#set_nick'

  resources :order, except: :index
  resources :product, only: :show

  root to: 'basket#show'
end
