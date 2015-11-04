Vedastore::LanguageString.class_eval do
  include Vedaspector::Entity
  
  def inspector_title_string
    "Language String: #{text} (#{language})"
  end
end
