Vedastore::InternationalizedText.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    if label
      "Internationalized Text: #{label}"
    else
      "Internationalized Text"
    end
  end

  present_as_value type: String, get: :preferred_language_text, store: :set_preferred_language_text

  def preferred_language_text
    preferred_language = VEDaspector::Application.config.preferred_language
    found_string = language_strings.find(language_strings.first) {|s| s.language == preferred_language }
    if found_string
      found_string.text
    else
      nil
    end
  end

  def set_preferred_language_text(text)
    preferred_language = VEDaspector::Application.config.preferred_language
    string = language_strings.find(language_strings.first) {|s| s.language == preferred_language }
    if string
      string.text = text
    else
      string = Vedastore::LanguageString.new language: preferred_language, text: text
      language_strings << string
    end
    string.save!
  end

end
