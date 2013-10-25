require 'faker'

FactoryGirl.define do
  factory :item do |w| 
    w.type "Item"
    w.title { Faker::Lorem.sentence(3, true, 5) }
    w.sort_title { Faker::Lorem.sentence(2, true, 5) }
    w.date_uploaded DateTime.now.utc # probably should be randomized
    w.date_modified DateTime.now.utc # probably should be randomized
  end 
end
