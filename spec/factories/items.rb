require 'faker'

FactoryGirl.define do

  factory :item do |i| 
    i.type "Item"
    i.title { Faker::Lorem.sentence(3, true, 5) }
    i.sort_title { Faker::Lorem.sentence(2, true, 5) }
    # i.date_uploaded DateTime.now.utc # probably should be randomized
    # i.date_modified DateTime.now.utc # probably should be randomized
  end

  # Not working. See ./text.rb
  # factory :text, parent: :item do |t|
  #   # FactoryGirl.attributes_for(:item)
  #   t.type "Text"
  #   t.description { Array.new(rand(0..5)) { Faker::Lorem.sentence(5, true, 3) } }
  #   t.language { Array.new(rand(0..3)) { Faker::Lorem.word[0..2] } }
  #   t.subject { Array.new(rand(0..5)) { Faker::Lorem.sentence(1, true, 3) } }
  #   t.toc { Faker::Lorem.sentence(5, true, 3) }
  # end

end

