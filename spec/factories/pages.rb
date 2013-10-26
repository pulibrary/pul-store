require 'faker'

FactoryGirl.define do
  factory :page do |p|
    p.type "Page"
    p.display_label { Faker::Lorem.sentence(1, true, 3)  }
    p.sort_order { Faker::Number.digit }
    # p.date_uploaded DateTime.now.utc
    # p.date_modified DateTime.now.utc
  end
end



