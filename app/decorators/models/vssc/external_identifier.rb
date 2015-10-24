Vssc::ExternalIdentifier.class_eval do
    def inspector_title_string
        "External Identifier: #{identifier_type} #{value}"
    end
end
