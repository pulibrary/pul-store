class CreatePulStoreLaeGenres < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_genres do |t|
      t.string :pul_label
      t.string :tgm_label
      t.string :lcsh_label
      t.integer :dimensions
      t.string :dimensions_unit
      t.string :uri
      t.text :scope_note
      t.timestamps
    end
  end
end
