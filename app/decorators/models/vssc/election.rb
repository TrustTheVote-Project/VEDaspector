Vssc::Election.class_eval do
    def inspector_title_string
        if name
            "Election: #{name.inspector_preferred_text}"
        else
            "Unnamed Election"
        end
    end
end
