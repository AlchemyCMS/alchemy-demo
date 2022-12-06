Rails.application.routes.draw do
  mount HealthBit.rack => "/healthz"
  mount Alchemy::Engine => "/"
end
