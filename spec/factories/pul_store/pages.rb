require 'faker'

FactoryGirl.define do
  factory :page, :class => PulStore::Page do |p|
    p.display_label { Faker::Lorem.sentence(1, true, 3)  }
    p.sort_order { Faker::Number.digit }
    # p.date_uploaded DateTime.now.utc
    # p.date_modified DateTime.now.utc
  end
end



