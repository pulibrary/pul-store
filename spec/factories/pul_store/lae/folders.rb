# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :lae_folder, :class => 'PulStore::Lae::Folder' do |f|
    f.project_id { FactoryGirl.create(:project).pid } # not sure if this is best...
    f.title { Faker::Lorem.sentence(3, true, 5) }
    f.sort_title { Faker::Lorem.sentence(2, true, 5) }
    f.barcode "32101067700821"
  end
end
