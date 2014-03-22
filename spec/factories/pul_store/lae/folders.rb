FactoryGirl.define do

  # TEST_BARCODES ||= YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))

  factory :lae_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.genre { PulStore::Lae::Genre.order("RAND()").first.pul_label }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.physical_number { (Faker::Number.digit.to_i+1).to_s }
  end

  factory :lae_prelim_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.genre {  PulStore::Lae::Genre.order("RAND()").first.pul_label }
    f.physical_number { (Faker::Number.digit.to_i+1).to_s }
  end

  factory :lae_core_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.date_created { Date.current.year }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.genre { PulStore::Lae::Genre.order("RAND()").first.pul_label }
    f.geographic_origin { PulStore::Lae::Area.order("RAND()").first.label }
    f.geographic_subject { Array.new(rand(1..2)) { PulStore::Lae::Area.order("RAND()").first.label } }
    f.physical_number { (Faker::Number.digit.to_i+1).to_s }
    f.language { Array.new(rand(1..2)) { ['English','Spanish','Portuguese'].sample } }
    f.rights { Faker::Lorem.sentence(5, true, 12) }
    f.sort_title { Faker::Lorem.sentence(2, true, 5) }
    f.subject  { Array.new(rand(1..3)) { Faker::Lorem.sentence(1,true,3) } }
    f.title { Faker::Lorem.sentence(3, true, 5) }
  end

  factory :lae_core_folder_with_pages, :class => 'PulStore::Lae::Folder' do |f|
    f.barcode { TEST_BARCODES.pop }
    f.date_created { Date.current.year }
    f.width_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.height_in_cm { (Faker::Number.digit.to_i+1).to_s }
    f.genre { PulStore::Lae::Genre.order("RAND()").first.pul_label }
    f.geographic_origin { PulStore::Lae::Area.order("RAND()").first.label }
    f.geographic_subject { Array.new(rand(1..2)) { PulStore::Lae::Area.order("RAND()").first.label } }
    f.language { Array.new(rand(1..2)) { ['English','Spanish','Portuguese'].sample } }
    f.physical_number { (Faker::Number.digit.to_i+1).to_s }
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
