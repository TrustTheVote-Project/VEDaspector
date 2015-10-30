Vssc::Office.class_eval do
  include VsscEntity

  def inspector_title_string
    if name
      "Office: #{name.preferred_language_text}"
    else
      "Unnamed Office"
    end
  end
end
