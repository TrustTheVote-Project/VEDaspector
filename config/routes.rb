Rails.application.routes.draw do
  get '/', to: 'entities#index'
  get '/:entity_type/', to: 'entities#list'
  get '/:entity_type/:entity_id', to: 'entities#show'
  get '/:entity_type/:entity_id/:entity_action', to: 'entities#entity_action'
end
