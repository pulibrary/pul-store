# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lae_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode "32101067661197"
    f.project_id { FactoryGirl.create(:project).pid } # not sure if this is best...
  end

  factory :lae_prelim_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode "32101067661197"
    f.project_id { FactoryGirl.create(:project).pid }
    f.extent { Faker::Lorem.sentence(3, true, 4) }
    f.genre { Faker::Lorem.word }
  end

  factory :lae_core_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode "32101067661197"
    f.project_id { FactoryGirl.create(:project).pid }
    f.date_created { Date.current }
    f.extent { Faker::Lorem.sentence(3, true, 4) }
    f.genre { Faker::Lorem.word }
    f.geographic  { Array.new(rand(1..2)) { Faker::Lorem.sentence(1,true,2) } }
    f.language { Array.new(rand(1..2)) { Faker::Lorem.word } }
    f.rights { Faker::Lorem.sentence(5, true, 12) }
    f.sort_title { Faker::Lorem.sentence(2, true, 5) }
    f.subject  { Array.new(rand(1..3)) { Faker::Lorem.sentence(1,true,3) } }
    f.title { Faker::Lorem.sentence(3, true, 5) }
  end
end
