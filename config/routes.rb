ChinaCity::Engine.routes.draw do
  root to: 'data#index'
  get ':id', to: 'data#show'
end
