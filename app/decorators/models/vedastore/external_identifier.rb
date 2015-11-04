Vedastore::ExternalIdentifier.class_eval do
  include Vedaspector::Entity
  def inspector_title_string
    "External Identifier: #{identifier_type} #{value}"
  end
end
