class CreatePulStoreLaeAreas < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_areas do |t|
      t.string :label
      t.string :iso_3166_2_code
      t.string :gac_code
    end
    add_index :pul_store_lae_areas, :label, unique: true
  end
end
