FactoryGirl.define do
  factory :lae_box, :class => 'PulStore::Lae::Box' do |b|
    b.barcode "32101067661197"
    b.project_id { FactoryGirl.create(:project).pid }
  end

  factory :lae_box_with_prelim_folders, :class => 'PulStore::Lae::Box' do |b|
    b.barcode "32101067661197"
    b.project_id { FactoryGirl.create(:project).pid }
    b.folders  { Array.new(5) { FactoryGirl.create(:lae_prelim_folder) } }
  end

  factory :lae_box_with_core_folders_with_pages, :class => 'PulStore::Lae::Box' do |b|
    b.barcode "32101067661197"
    b.project_id { FactoryGirl.create(:project).pid }
    b.folders  { Array.new(5) { FactoryGirl.create(:lae_core_folder_with_pages) } }
  end
end
