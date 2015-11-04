Vedastore::ExternalIdentifierCollection.class_eval do
  include Vedaspector::Entity

  preferred_name "External Identifiers"
  present_as_collection :external_identifiers

end
