# This migration comes from vssc_rails (originally 4)
class CreateVsscExternalIdentifiers < ActiveRecord::Migration
  def change
    create_table :vssc_external_identifier_collections do |t|
      t.string :identifiable_type
      t.integer :identifiable_id
      t.string :label
      
      t.timestamps null: false
    end
    
    create_table :vssc_external_identifiers do |t|
      t.integer :external_identifier_collection_id
      
      t.string :identifier_type
      t.string :other_type
      t.string :value
      
      t.string :label
      
      t.timestamps null: false
    end
    add_index :vssc_external_identifier_collections, [:identifiable_type, :identifiable_id], name: :vssc_identifiable
  end  
end
