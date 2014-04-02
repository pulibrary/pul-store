class CreatePulStoreLaeCategories < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_categories do |t|
      t.string :label
    end
    add_index :pul_store_lae_categories, :label, unique: true
  end
end
