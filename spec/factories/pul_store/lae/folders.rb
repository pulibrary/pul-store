
FactoryGirl.define do

  factory :lae_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.genre { Faker::Lorem.word }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
  end

  factory :lae_prelim_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.genre { Faker::Lorem.word }
  end

  factory :lae_core_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.date_created { Date.current }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.genre { Faker::Lorem.word }
    f.geographic  { Array.new(rand(1..2)) { Faker::Lorem.sentence(1,true,2) } }
    f.language { Array.new(rand(1..2)) { ['eng','spa','por'].sample } }
    f.rights { Faker::Lorem.sentence(5, true, 12) }
    f.sort_title { Faker::Lorem.sentence(2, true, 5) }
    f.subject  { Array.new(rand(1..3)) { Faker::Lorem.sentence(1,true,3) } }
    f.title { Faker::Lorem.sentence(3, true, 5) }
  end

  factory :lae_core_folder_with_pages, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.date_created { Date.current }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.genre { Faker::Lorem.word }
    f.geographic  { Array.new(rand(1..2)) { Faker::Lorem.sentence(1,true,2) } }
    f.language { Array.new(rand(1..2)) { Faker::Lorem.word } }
    f.rights { Faker::Lorem.sentence(5, true, 12) }
    f.sort_title { Faker::Lorem.sentence(2, true, 5) }
    f.subject  { Array.new(rand(1..3)) { Faker::Lorem.sentence(1,true,3) } }
    f.title { Faker::Lorem.sentence(3, true, 5) }
    # Rspec wants this:
    f.pages { Array.new(2) { FactoryGirl.create(:page) } }
    # Console wants this:
    # after(:create) do |folder|
    #   2.times do
     #     folder.pages << FactoryGirl.create(:page)
    #   end
    # end
    

  end
end
