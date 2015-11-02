class EntitiesController < ApplicationController

  def initialize
    super
    @linked_entity_num_shown_properties = 10

    @collection_page_size = 30
    @linked_collection_page_size = 10
  end

  ### Shared Methods

  def lookup_vssc_class(name)
    VsscEntity::ENTITY_CLASSES.find { |klass| klass.name.demodulize == name }
  end

  # Returns Ruby class for a viewable VSSC entity type, or nil.
  def lookup_entity_type(entity_name)
    # TODO: whitelist specific classes?
    lookup_vssc_class(entity_name.titleize.delete(' ').singularize) or
      lookup_vssc_class(entity_name.titleize.delete(' '))
  end

  def assign_entity_type!
    input_entity_type = params[:entity_type]
    @entity_type = lookup_entity_type input_entity_type
    raise "Invalid entity type: #{input_entity_type}" unless @entity_type
  end

  def assign_entity!
    entity_id = params[:entity_id]
    @entity = @entity_type.find(entity_id)
    raise "Invalid entity: #{entity_id}" unless @entity
  end

  def assign_collection_property!
    collection_name = params[:collection]
    @collection = @entity.entity_property collection_name.to_sym
    @base_collection_url = view_context.collection_view_link @collection
    @current_page = (params[:page_number] || 1).to_i

    if @current_page < 1 || @current_page > (@collection.value.size / @collection_page_size).ceil
      return redirect_to @base_collection_url
    end

    raise "Invalid collection '#{collection_name}' for #{@entity_type}" unless @collection
  end

  ### Routes

  def index
    redirect_to '/election_reports'
  end

  def list
    assign_entity_type!

    @is_root_entity = @entity_type == Vssc::ElectionReport
    @entities = @entity_type.all
  end

  def create
    render text: "TODO"
  end

  def save
    render text: "TODO"
  end

  ### Entity Actions

  def show
    assign_entity_type!
    assign_entity!
  end

  def edit
    assign_entity_type!
    assign_entity!
  end

  def update
    assign_entity_type!
    assign_entity!

    @entity.update_entity(params[:entity])
    redirect_to view_context.entity_view_link(@entity)
  end

  def delete
    assign_entity_type!
    assign_entity!

    @entity.destroy

    redirect_to '/'
  end

  def entity_action
    assign_entity_type!
    assign_entity!

    action = params[:entity_action]

    if @entity.has_entity_action? action
      @entity.send(action, self)
    else
      raise "Unexpected action '#{action}' for #{@entity}"
    end
  end

  def collection_list
    assign_entity_type!
    assign_entity!
    assign_collection_property!
  end

  def collection_insert
    assign_entity_type!
    assign_entity!

    render text: "TODO"
  end

  def collection_insert_save
    render text: "TODO"
  end

end
