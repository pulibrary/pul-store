require 'faker'

FactoryGirl.define do

  factory :item do |i| 
    i.type "Item"
    i.title { Faker::Lorem.sentence(3, true, 5) }
    i.sort_title { Faker::Lorem.sentence(2, true, 5) }
    # i.date_uploaded DateTime.now.utc # probably should be randomized
    # i.date_modified DateTime.now.utc # probably should be randomized
  end

end

