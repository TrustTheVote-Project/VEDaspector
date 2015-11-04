Vedastore::Election.class_eval do
  include Vedaspector::Entity

  def inspector_title_string
    if name
      "Election: #{name.preferred_language_text}"
    else
      "Unnamed Election"
    end
  end
end
