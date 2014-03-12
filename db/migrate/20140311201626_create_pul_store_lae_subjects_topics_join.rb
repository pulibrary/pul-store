class CreatePulStoreLaeSubjectsTopicsJoin < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_subjects_topics do |t|
      t.integer :topic_id
      t.integer :subject_id
    end
  end
end
