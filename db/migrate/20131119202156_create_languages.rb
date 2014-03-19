class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :uri
      t.string :code
      t.string :label
    end
    add_index :languages, :label, unique: true
  end
end
