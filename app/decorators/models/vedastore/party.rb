Vedastore::Party.class_eval do
  include Vedaspector::Entity

  def inspector_title_string
    if name
      "Party: #{name.preferred_language_text}"
    else
      "Unnamed Party"
    end
  end
end
