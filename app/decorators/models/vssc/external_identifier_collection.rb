Vssc::ExternalIdentifierCollection.class_eval do
  include VsscEntity

  preferred_name "External Identifiers"
  present_as_collection :external_identifiers

end
