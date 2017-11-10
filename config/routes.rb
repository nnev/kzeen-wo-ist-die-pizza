Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  patch 'set_nick', to: 'tool#set_nick'

  resource :order, only: [:show, :destroy], controller: :order do
    patch :toggle_paid, on: :member
    post   'item/create', to: 'order#item_create'
    get    'item/:index', to: 'order#item_show',  as: :item, constraints: { :index => /\d/ }
    post   'item/:index', to: 'order#item_update',           constraints: { :index => /\d/ }
    delete 'item/:index', to: 'order#item_destroy',          constraints: { :index => /\d/ }
  end
  resources :product, only: :show

  root to: 'basket#show'
end
