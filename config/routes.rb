Rails.application.routes.draw do
  get 'forecast', to: 'forecasts#index'
end
