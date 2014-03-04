require 'faker'

FactoryGirl.define do

  factory :project, :class => PulStore::Project do |i| 
    i.label { Faker::Lorem.sentence(3, true, 7) }
    i.description { Faker::Lorem.paragraph }
    i.identifier { Faker::Lorem.word }
  end

end
