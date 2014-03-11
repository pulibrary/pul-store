class CreatePulStoreLaeSubjects < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_subjects do |t|
      t.string :value
    end
    add_index :pul_store_lae_subjects, :value, unique: true
  end
end
