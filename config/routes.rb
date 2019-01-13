def create_routes(router)
  router.draw do
    # root to: 'cats#index'
    # resources :cats
    # resources :users, except: [:edit, :update] do 
    #   resources :cats do 
    #     collection do
    #       get :dog
    #     end
    #   end
    # end
    # resources :users, except: [:edit, :update] do 
    #   member do 
    #     get :dog
    #   end
    # end
    # resource :sessions, only: [:new, :create, :destroy]
    # patch '/dogs/:id', to: 'cats#update'
    # patch '/dogs', to: 'cats#index'


    root to: 'cats#index'
    resources :cats
    resources :users, except: [:edit, :update]
    resource :sessions, only: [:new, :create, :destroy]
  end

end