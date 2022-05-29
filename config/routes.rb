Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  mount Alchemy::GraphQL::Engine => '/'
  mount Alchemy::Engine => '/'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
