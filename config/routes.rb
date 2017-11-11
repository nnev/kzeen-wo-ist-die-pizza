Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  patch 'set_nick',     to: 'misc#set_nick'
  patch 'toggle_admin', to: 'misc#toggle_admin'
  get   'privacy',      to: 'misc#privacy'

  scope 'order' do
    # vanity routes for 'self'
    get    '',            to: 'order#show',       as: :my_order
    patch  'toggle_paid', to: 'order#toggle_paid'

    scope ':order_id', order_id: /\d+/ do
      # mostly for admin
      get    '',            to: 'order#show',        as: :order
      delete '',            to: 'order#destroy'
      patch  'toggle_paid', to: 'order#toggle_paid', as: :order_toggle_paid

      # not user visible, thus no vanity routing
      post   'item/create', to: 'order#item_create'
      get    'item/:index', to: 'order#item_show',  as: :item, index: /\d+/
      post   'item/:index', to: 'order#item_update',           index: /\d+/
      delete 'item/:index', to: 'order#item_destroy',          index: /\d+/
    end
  end

  resources :product, only: :show

  resources :basket, only: :show do
    member do
      patch :toggle_cancelled
      patch :delivery_arrived
      patch :submit
      patch :unsubmit
    end
  end

  root to: 'basket#show'
end
