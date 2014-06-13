require 'faker'

FactoryGirl.define do
  factory :page, :class => PulStore::Page do |p|
    p.display_label { Faker::Lorem.sentence(1, true, 3)  }
    p.sort_order { Faker::Number.digit.to_i }
    p.text_id { FactoryGirl.create(:text).pid }
    p.project { PulStore::Project.last }
  end

  factory :lae_page, :class => PulStore::Page do |p|
    p.display_label { Faker::Lorem.sentence(1, true, 3)  }
    p.sort_order { Faker::Number.digit }
    p.project { PulStore::Lae::Provenance::PROJECT }
  end
end



