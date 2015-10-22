class EntitiesController < ApplicationController

    # Returns Ruby class for a viewable VSSC entity type, or nil.
    def lookup_entity_type(entity_name)
        klass = Object.const_get("Vssc").const_get(entity_name.titleize.delete(' '))
        # TODO: whitelist specific classes?
        klass
    end

    def index
        redirect_to '/election_reports'
    end

    def list
        input_entity_type = params[:entity_type].singularize
        @entity_type = lookup_entity_type input_entity_type
        raise "Invalid entity type: #{input_entity_type}" unless @entity_type

        @show_welcome_message = @entity_type == Vssc::ElectionReport
        @entities = @entity_type.all
    end

    def show
        input_entity_type = params[:entity_type].singularize
        @entity_type = lookup_entity_type input_entity_type
        raise "Invalid entity type: #{input_entity_type}" unless @entity_type

        entity_id = params[:entity_id]
        @entity = @entity_type.find(entity_id)

        @max_shown_collection_items = 10
        @max_shown_subentity_properties = 10
    end

end
