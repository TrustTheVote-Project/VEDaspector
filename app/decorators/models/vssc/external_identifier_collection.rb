Vssc::ExternalIdentifierCollection.class_eval do

    def inspector_preferred_name
      "External Identifiers"
    end

    def inspector_preferred_classification
        :collection
    end

    def inspector_preferred_value
        external_identifiers
    end
end
