Vssc::Office.class_eval do
    def inspector_title_string
        if name
            "Office: #{name.inspector_preferred_text}"
        else
            "Unnamed Office"
        end
    end
end
