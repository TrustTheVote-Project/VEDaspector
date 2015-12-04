require 'test_helper'

class EntityTest < ActiveSupport::TestCase

  # Tests basic entity update
  test "Updating an Election" do
    election_name = 'My First Election'
    election = Vedastore::Election.new
    election.update_and_save!({
      'name' => { 'strings' => [{'language' => 'en-US', 'text' => election_name }]},
      'election_type' => 'partisan-primary-closed'
    })

    assert_equal election_name, election.name.preferred_language_text
    assert_equal 'partisan-primary-closed', election.election_type
  end

  # Tests adding an entity to a parent entity
  test "Add an Election to an Election Report" do
    election_report = Vedastore::ElectionReport.new

    election_property = election_report.entity_property :election

    election = Vedastore::Election.new
    election.update_and_save!({
      'name' => { 'strings' => [{'language' => 'en-US', 'text' => 'My First Election' }]},
      'election_type' => 'partisan-primary-closed'
    }, parent_property: election_property)

    assert_equal election_report.election_id, election.id
  end

  # Tests adding an entity to a parent collection
  test "Add an External Identifier to an Election" do
    election = Vedastore::Election.new
    external_identifier_property = election.entity_property :external_identifier_collection

    assert external_identifier_property.collection?

    external_identifier = Vedastore::ExternalIdentifier.new
    external_identifier.update_and_save!({
      'type' => 'fips',
      'value' => '36'
    }, parent_property: external_identifier_property)
    
    assert_equal 1, election.external_identifier_collection.external_identifiers.size
  end

  # Tests saving a serialized Array of strings
  test "Set emails on a ContactInformation" do
    contact_information = Vedastore::ContactInformation.new
    contact_information.update_and_save!({
      'email' => ['alice@example.com', 'bob@example.com']
    })

    assert_equal 2, contact_information.email.size
  end

end
