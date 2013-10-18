require 'faker'

FactoryGirl.define do 
  factory :work do |w| 
    w.type "Work"
    w.title { Faker::Lorem.sentence(3, true, 5) }
    w.sort_title { Faker::Lorem.sentence(2, true, 5) }
    # TODO: random (valid) creator/contributor combinations.
  end 
end