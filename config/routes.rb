ChinaCity::Engine.routes.draw do
  root to: 'data#show'
  get ':id', to: 'data#show'
end
