class CreatePulStoreLaeTopics < ActiveRecord::Migration
  def change
    create_table :pul_store_lae_topics do |t|
      t.string :value
    end
    add_index :pul_store_lae_topics, :value, unique: true
  end
end
