Vssc::ExternalIdentifier.class_eval do
  include VsscEntity
  def inspector_title_string
    "External Identifier: #{identifier_type} #{value}"
  end
end
