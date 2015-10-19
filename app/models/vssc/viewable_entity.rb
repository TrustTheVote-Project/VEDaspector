Vssc::BallotStyle.class_eval do
    def inspector_title_string
        if object_id
            "Ballot Style: #{object_id}"
        else
            "Unidentified Ballot Style"
        end
    end
end

Vssc::Candidate.class_eval do
    def inspector_title_string
        "Contest: #{ballot_name.preferred_language_text}"
    end
end

Vssc::Contest.class_eval do
    def inspector_title_string
        "Contest: #{name}"
    end
end

Vssc::OrderedContest.class_eval do
    def inspector_title_string
        "OrderedContest: #{contest_identifier}"
    end
end

Vssc::Election.class_eval do

    def inspector_title_string
        "Election: #{name.preferred_language_text}"
    end

end

Vssc::ElectionReport.class_eval do

    def inspector_title_string
        s = "Election Report: #{election.name.preferred_language_text}"
        if generated_date
            s += " (#{generated_date.to_formatted_s(:short_date)})"
        end
        s
    end

end

Vssc::InternationalizedText.class_eval do

    def preferred_language_text
        preferred_language = VEDaspector::Application.config.preferred_language
        found_string = language_strings.find(language_strings.first) {|s| s.language == preferred_language }
        found_string.nil? ? nil : found_string.text
    end

end


Vssc::Office.class_eval do
    def inspector_title_string
        "Office: #{electoral_district_identifier}"
    end
end

Vssc::Party.class_eval do
    def inspector_title_string
        "Party: #{name.preferred_language_text}"
    end
end

Vssc::ReportingUnit.class_eval do
    def inspector_title_string
        "Reporting Unit: #{name || 'Unnamed'}"
    end
end

Vssc::Enum::IdentifierType.class_eval do
    def inspector_title_string
        "Idnetifier: #{identifier_type} #{Value}"
    end
end

module Vssc::ViewableEntity

    # Returns Ruby class for a viewable VSSC entity type, or nil.
    def self.lookup_entity_type(entity_name)
        klass = Object.const_get("Vssc").const_get(entity_name.titleize.delete(' '))
        # TODO: whitelist specific classes?
        klass
    end

end

