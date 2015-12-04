Vedastore::InternationalizedText.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    if label
      "Internationalized Text: #{label}"
    else
      "Internationalized Text"
    end
  end

  present_as_value display: 'properties/internationalized_text', editor: 'editors/internationalized_text', store: :set_language_strings

  def preferred_language_text
    preferred_language = VEDaspector::Application.config.preferred_language
    found_string = language_strings.find(language_strings.first) {|s| s.language == preferred_language }
    if found_string
      found_string.text
    else
      nil
    end
  end

  def set_language_strings(input)
    self.label = input['label']
    new_strings = input['strings']
      .reject {|s| s['language'].blank? && s['text'].blank? }
      .map { |s| Vedastore::LanguageString.new language: s['language'], text: s['text'] }
    language_strings.replace(new_strings)
  end

end
