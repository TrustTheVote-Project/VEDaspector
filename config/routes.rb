Rails.application.routes.draw do
  get '/', to: 'entities#index'
  get '/:entity_type/', to: 'entities#list'
  get '/:entity_type/new', to: 'entities#create'
  post '/:entity_type/new', to: 'entities#save'

  get '/:entity_type/:entity_id', to: 'entities#show'
  get '/:entity_type/:entity_id/edit', to: 'entities#edit'
  post '/:entity_type/:entity_id/edit', to: 'entities#update'
  delete '/:entity_type/:entity_id', to: 'entities#delete'

  get '/:entity_type/:entity_id/collection/:collection', to: 'entities#collection_list'
  get '/:entity_type/:entity_id/collection/:collection/:page_number', to: 'entities#collection_list'
  get '/:entity_type/:entity_id/collection/:collection/add', to: 'entities#collection_insert'
  post '/:entity_type/:entity_id/collection/:collection/add', to: 'entities#collection_insert_save'

  # Place below other routes
  get '/:entity_type/:entity_id/:entity_action', to: 'entities#entity_action'

end
