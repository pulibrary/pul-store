require 'faker'

FactoryGirl.define do

  factory :item do |i|
    i.project_id { FactoryGirl.create(:project).pid } # not sure if this is best...
    i.type "Item"
    i.title { Faker::Lorem.sentence(3, true, 5) }
    i.sort_title { Faker::Lorem.sentence(2, true, 5) }
  end

end

