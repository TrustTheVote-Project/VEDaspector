Vssc::Candidate.class_eval do
    def inspector_title_string
        if ballot_name
            "Candidate: #{ballot_name.inspector_preferred_text}"
        else
            "Unnamed Candidate"
        end

    end
end



