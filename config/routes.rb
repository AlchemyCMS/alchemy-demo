Rails.application.routes.draw do
  mount HealthBit.rack => "/healthz"

  namespace :admin do
    resources :events
  end

  mount Alchemy::Engine => "/"
end
