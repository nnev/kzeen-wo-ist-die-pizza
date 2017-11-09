Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  patch 'set_nick', to: 'tool#set_nick'

  resource :order, only: [:show], controller: :order do
    post   'item/create', to: 'order#item_create'
    get    'item/:index', to: 'order#item_show',  as: :item
    patch  'item/:index', to: 'order#item_update'
    delete 'item/:index', to: 'order#item_destroy'
  end
  resources :product, only: :show

  root to: 'basket#show'
end
