# This migration comes from vssc_rails (originally 26)
class CreateVsscAnnotatedStrings < ActiveRecord::Migration
  def change
    create_table :vssc_rails_vssc_annotated_strings do |t|
      t.text :value
      t.string :annotation
      t.timestamps null: false
    end
  end
end
