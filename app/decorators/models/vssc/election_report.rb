Vssc::ElectionReport.class_eval do
    def inspector_title_string
        if election and election.name
            s = "Election Report: #{election.name.inspector_preferred_text}"
            if generated_date
                s += " (#{generated_date.to_formatted_s(:short_date)})"
            end
            s
        else
            "Unnamed Election Report"
        end
    end
end
