Rails.application.routes.draw do
  get '/', to: 'entities#index'
  get '/:entity_type/', to: 'entities#list'
  get '/:entity_type/:entity_id', to: 'entities#show'
end
