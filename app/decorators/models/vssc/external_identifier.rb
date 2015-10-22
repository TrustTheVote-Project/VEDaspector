Vssc::ExternalIdentifier.class_eval do
    def inspector_title_string
        "#{identifier_type} #{value}"
    end
end
