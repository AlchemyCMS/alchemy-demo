Rails.application.routes.draw do
  mount Alchemy::GraphQL::Engine => '/'
  mount Alchemy::Engine => '/'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
