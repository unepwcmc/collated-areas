Rails.application.routes.draw do
  root to: 'home#index'

  get '/', to: 'home#index'
  post '/download', to: 'home#download'

  post '/list', to: 'home#list'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
