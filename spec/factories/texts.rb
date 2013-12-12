require 'faker'

FactoryGirl.define do
  # Note that text is a subclass of item. It would be nice to be able to inherit
  # some of the factory work from item.rb.
  # factory :text do |t| 
  #   # TODO: creator and contributor, and then catch validation errors in tests
  #   t.abstract { Array.new(rand(0..2)) { Faker::Lorem.paragraph(rand(1..7)) } }
  #   t.alternative_title { Array.new(rand(0..5)) { Faker::Lorem.sentence(5,true,3) } }
  #   t.audience { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
  #   t.citation { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
  #   t.date_created { rand(900..2000) }
  #   t.description { Array.new(rand(0..10)) { Faker::Lorem.paragraph(1,true,3) } }
  #   t.extent { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
  #   t.has_part { Array.new(rand(0..20)) { Faker::Lorem.sentence(3,true,5) } }
  #   t.language { Array.new(rand(0..5)) { Faker::Lorem.sentence(1,false,3) } }
  #   t.provenance { Array.new(rand(0..2)) { Faker::Lorem.paragraph(rand(1..7)) } }
  #   t.publisher { Array.new(rand(0..2)) { Faker::Lorem.sentence(3,true,3) } }
  #   t.rights { Array.new(rand(0..4)) { Faker::Lorem.sentence(5,true,3) } }
  #   t.series { Array.new(rand(0..2)) { Faker::Lorem.sentence(3,true,5) } }
  #   t.sort_title { Faker::Lorem.sentence(2,true,5) }
  #   t.subject { Array.new(rand(0..7)) { Faker::Lorem.sentence(1,true,3) } }
  #   t.title { Array.new(rand(1..2)) { Faker::Lorem.sentence(3,true,5) } }
  #   t.toc { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
  #   t.type "Text"
  # end

  factory :text do |t| 
    # TODO: creator and contributor, and then catch validation errors in tests
    t.abstract { Array.new(rand(0..2)) { Faker::Lorem.paragraph(rand(1..7)) } }
    t.alternative_title { Array.new(rand(0..5)) { Faker::Lorem.sentence(5,true,3) } }
    t.audience { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
    t.citation { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
    t.date_created { rand(900..2000) }
    t.description { Array.new(rand(0..10)) { Faker::Lorem.paragraph(1,true,3) } }
    t.extent { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
    t.has_part { Array.new(rand(0..20)) { Faker::Lorem.sentence(3,true,5) } }
    t.language { Array.new(rand(0..5)) { Faker::Lorem.sentence(1,false,3) } }
    t.provenance { Array.new(rand(0..2)) { Faker::Lorem.paragraph(rand(1..7)) } }
    t.publisher { Array.new(rand(0..2)) { Faker::Lorem.sentence(3,true,3) } }
    t.rights { Array.new(rand(0..4)) { Faker::Lorem.sentence(5,true,3) } }
    t.series { Array.new(rand(0..2)) { Faker::Lorem.sentence(3,true,5) } }
    t.sort_title { Faker::Lorem.sentence(2,true,5) }
    t.subject { Array.new(rand(0..7)) { Faker::Lorem.sentence(1,true,3) } }
    t.title { Array.new(rand(1..2)) { Faker::Lorem.sentence(3,true,5) } }
    t.toc { Array.new(rand(0..2)) { Faker::Lorem.sentence(5,true,3) } }
    t.type "Text"
  end

end


