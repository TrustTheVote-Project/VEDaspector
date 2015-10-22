Vssc::InternationalizedText.class_eval do

    def inspector_title_string
        if label
            "Internationalized Text: #{label}"
        else
            "Internationalized Text"
        end
    end

    def inspector_preferred_classification
        :value
    end

    def inspector_preferred_text
        preferred_language = VEDaspector::Application.config.preferred_language
        found_string = language_strings.find(language_strings.first) {|s| s.language == preferred_language }
        found_string.nil? ? nil : found_string.text
    end

end
