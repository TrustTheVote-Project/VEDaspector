Vssc::OrderedContest.class_eval do
    def inspector_title_string
        if contest_identifier
            "OrderedContest: #{contest_identifier}"            
        else
            "Unidentified OrderedContest"
        end
    end
end
