TEST_BARCODES ||= YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))
FactoryGirl.define do

  factory :lae_box, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
    b.project { PulStore::Lae::Provenance::PROJECT }
  end

  factory :lae_box_with_prelim_folders, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
    b.project { PulStore::Lae::Provenance::PROJECT }

    after(:create) do |box|
      3.times do
        box.folders << FactoryGirl.create(:lae_prelim_folder)
      end
    end
  end

  factory :lae_box_with_core_folders_with_pages, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
    b.project { PulStore::Lae::Provenance::PROJECT }
    b.discover_groups { ["all_project_discover", "lae_project_discover", "public"] }
    b.read_groups { ["all_project_readers", "lae_project_readers", "public"] }
    b.shareable { "true" }
    after(:create) do |box|
      2.times do 
        box.folders << FactoryGirl.create(:lae_core_folder_with_pages)
      end
    end
  end

  factory :lae_box_with_core_folders_with_pages_not_shared, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
    b.project { PulStore::Lae::Provenance::PROJECT }
    #b.read_groups { ["all_project_readers", "lae_project_readers", "public"] }
    #b.shareable { "true" }
    after(:create) do |box|
      2.times do 
        box.folders << FactoryGirl.create(:lae_core_folder_with_pages)
      end
    end
  end
end


