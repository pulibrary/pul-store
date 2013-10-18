require 'faker'


FactoryGirl.define do
  factory :text do |t|
    t.type "Text"
    t.title { Faker::Lorem.sentence(3, true, 5) }
    t.sort_title { Faker::Lorem.sentence(2, true, 5) }
    t.description { Faker::Lorem.sentence(3, true, 5) }
    t.subject { Faker::Lorem.sentence(3, true, 5) }
    t.language { Faker::Lorem.sentence(3, true, 5) }
  end
end