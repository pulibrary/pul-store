require 'faker'

FactoryGirl.define do 
  factory :work do |w| 
    w.type = "Work"
    title_word_count = 3 + rand(5)
    w.title { Faker::Lorem.words(num: title_word_count, supplemental: true) }
    w.sort_title = w.title.split[rand(1), w.title.split.length].join ' '
    # TODO: random (valid) creator/contributor combinations.
  end 
end