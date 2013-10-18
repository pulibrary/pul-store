require 'faker'

FactoryGirl.define do
  factory :text do |t|
    t.type "Text"
    t.title { Faker::Lorem.sentence(3, true, 5) }
    t.sort_title { Faker::Lorem.sentence(2, true, 5) }
    t.date_uploaded DateTime.now.utc # probably should be randomized
    t.date_modified DateTime.now.utc # probably should be randomized
    t.description { Faker::Lorem.sentence(5, true, 3) }
    t.subject { Faker::Lorem.sentence(5, true, 3) }
    t.language { Faker::Lorem.words(1) }
  end
end