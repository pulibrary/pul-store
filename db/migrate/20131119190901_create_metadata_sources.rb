class CreateMetadataSources < ActiveRecord::Migration
  def change
    create_table :metadata_sources do |t|
      t.string :label
      t.string :uri
      t.string :media_type
    end
  end
end
