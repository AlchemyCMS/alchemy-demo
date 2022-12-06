Rails.application.routes.draw do
  mount HealthBit.rack => "/healthz"
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  mount Alchemy::GraphQL::Engine => "/"
  mount Alchemy::Engine => "/"
end
