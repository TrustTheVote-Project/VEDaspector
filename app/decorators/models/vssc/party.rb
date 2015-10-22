Vssc::Party.class_eval do
    def inspector_title_string
        if name
            "Party: #{name.inspector_preferred_text}"
        else
            "Unnamed Party"
        end
    end
end
