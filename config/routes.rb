Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :api, defaults: { format: :json}, constraints: { subdomain: 'api'}, path: "/" do
    namespace :v1, path: "/", constraints: ApiVersionConstraint.new(version: 1) do
      resources :tasks
    end

    namespace :v2, path: "/", constraints: ApiVersionConstraint.new(version: 2, default: true) do
      resources :tasks
    end 
  end

end
