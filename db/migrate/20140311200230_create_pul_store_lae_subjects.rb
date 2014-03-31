class CreatePulStoreLaeSubjects < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_subjects do |t|
      t.string :label
      t.string :uri
      t.integer :category_id
    end
    add_index :pul_store_lae_subjects, :label, unique: true
  end
end
