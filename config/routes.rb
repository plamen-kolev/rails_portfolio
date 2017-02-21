Rails.application.routes.draw do
  devise_for :admins
  devise_for :users
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root 'pages#index'
  get 'articles.html', to: 'articles#index', as: 'articles'
  get '/articles/:slug.html', to: 'articles#show', as: 'article'
  get '/creative.html', to: 'creatives#index', as: 'creative'
  get '/biography.html', to: 'biography#index', as: 'biography'
  
  get '/four_oh_four', to: 'pages#error_404', as: 'fourohfour', :via => :all
  get '/cv.pdf', to: 'biography#cv', as: 'cv'

end
