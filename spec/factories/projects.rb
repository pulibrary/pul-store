require 'faker'

FactoryGirl.define do

  factory :project do |i| 
    i.display_label { Faker::Lorem.sentence(3, true, 7) }
    i.description { Faker::Lorem.paragraph }
    i.project_identifier { Faker::Lorem.word }
  end

end
