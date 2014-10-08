require 'faker'

FactoryGirl.define do

  factory :item, :class => PulStore::Item do |i|
    i.project { PulStore::Project.last }
    i.title { Array.new(rand(1..2)) { Faker::Lorem.sentence(3, true, 5) } }
    i.sort_title { Faker::Lorem.sentence(2, true, 5) }
  end

end

