class AddIndexToPulStoreLaeGenre < ActiveRecord::Migration
  def change
    add_index :pul_store_lae_genres, :pul_label
  end
end
