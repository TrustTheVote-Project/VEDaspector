# This migration comes from vssc_rails (originally 27)
class CreateVsscElectionAdministrations < ActiveRecord::Migration
  def change
    create_table :vssc_election_administrations do |t|
      t.integer  :contact_information_id
      t.string :name
      
      t.timestamps null: false
    end
    add_index :vssc_election_administrations, :contact_information_id, name: :vssc_election_admin_contact_information
    
    create_table :vssc_election_administration_official_id_refs do |t|
      t.integer :election_administration_id
      t.string :election_official_id_ref
    end
    add_index :vssc_election_administration_official_id_refs, [:election_administration_id, :election_official_id_ref], name: :vssc_election_admin_official_ref
    
  end  
end
