Rails.application.routes.draw do
  scope :auth do
    post :register, to: 'authentication#register'
    post :login, to: 'authentication#login'
  end

  resources :users, param: :username, only: %i[index show update] do
    post :roles, param: :username, to: 'users#add_role'
  end

  resources :merchants, only: [:index] do
    get :items, to: 'merchants#show_items'
    post :items, to: 'merchants#create_item'

    resources :items, only: :nothing do
      patch :stock, param: :item_id, to: 'merchants#update_item_stock'
    end
  end

  scope :user do
    post '/password/forgot', to: 'passwords#forgot'
    post '/password/reset', to: 'passwords#reset'
    put '/password/update', to: 'passwords#update'
    post '/email/update', to: 'emails#update'
    post '/email/new', to: 'emails#new'
  end

  get '/*a', to: 'application#not_found'

end
