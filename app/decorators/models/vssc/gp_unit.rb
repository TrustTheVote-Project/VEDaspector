Vssc::GpUnit.class_eval do
    def inspector_title_string
        if name
            "GP Unit: #{name.inspector_preferred_text}"
        else
            "Unnamed GP Unit"
        end
    end
end
