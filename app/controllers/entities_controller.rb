class EntitiesController < ApplicationController

  def initialize
    super
    @max_shown_collection_items = 10
    @max_shown_subentity_properties = 10
  end

  def lookup_vssc_class(name)
    VsscEntity::ENTITY_CLASSES.find { |klass| klass.name.demodulize == name }
  end

  # Returns Ruby class for a viewable VSSC entity type, or nil.
  def lookup_entity_type(entity_name)
    # TODO: whitelist specific classes?
    lookup_vssc_class(entity_name.titleize.delete(' ').singularize) or
      lookup_vssc_class(entity_name.titleize.delete(' '))
  end

  def index
    redirect_to '/election_reports'
  end

  def list
    input_entity_type = params[:entity_type]
    @entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless @entity_type

    @show_welcome_message = @entity_type == Vssc::ElectionReport
    @entities = @entity_type.all
  end

  def show
    input_entity_type = params[:entity_type]
    @entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless @entity_type

    entity_id = params[:entity_id]
    @entity = @entity_type.find(entity_id)

    @entity_actions = [
      {:title => "Edit", :action_path => 'edit', :button_class => 'btn-default'}
    ]

    if @entity.respond_to? :inspector_action_buttons
      @entity_actions += @entity.inspector_action_buttons(request)
    end
  end

  def edit
    input_entity_type = params[:entity_type]
    @entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless @entity_type

    entity_id = params[:entity_id]
    @entity = @entity_type.find(entity_id)
  end

  def update
    input_entity_type = params[:entity_type]
    @entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless @entity_type

    entity_id = params[:entity_id]
    @entity = @entity_type.find(entity_id)

    @entity.update_entity(params[:entity])

    redirect_to view_context.entity_view_link(@entity)
  end

  def entity_action
    input_entity_type = params[:entity_type]
    entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless entity_type

    entity_id = params[:entity_id]
    entity = entity_type.find(entity_id)

    action = params[:entity_action]

    if entity.respond_to? action
      entity.send(action, self)
    else
      raise "Unexpected action '#{action}' for #{entity}"
    end
  end

end
