Vssc::LanguageString.class_eval do
  include VsscEntity
  
  def inspector_title_string
    "Language String: #{text} (#{language})"
  end
end
