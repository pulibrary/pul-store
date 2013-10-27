require 'faker'

FactoryGirl.define do
  # Note that text is a subclass of item. It would be nice to be able to inherit
  # some of the factory work from item.rb.
  factory :text do |t| 
    t.type "Text"
    t.title { Faker::Lorem.sentence(3, true, 5) }
    t.sort_title { Faker::Lorem.sentence(2, true, 5) }
    t.description { Array.new(rand(0..5)) { Faker::Lorem.sentence(5, true, 3) } }
    t.language { Array.new(rand(1..3)) { Faker::Lorem.word[0..2] } }
    t.subject { Array.new(rand(0..5)) { Faker::Lorem.sentence(1, true, 3) } }
    t.toc { Faker::Lorem.sentence(5, true, 3) }
  end

end


