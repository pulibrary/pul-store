FactoryGirl.define do

  factory :lae_box, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
  end

  factory :lae_box_with_prelim_folders, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
    # Rspec wants this:
    b.folders { Array.new(5) { FactoryGirl.create(:lae_prelim_folder) } }
    # Console wants this:
    # after(:create) do |box|
    #   2.times do 
    #     box.folders << FactoryGirl.create(:lae_prelim_folder)
    #   end
    # end
  end

  factory :lae_box_with_core_folders_with_pages, :class => 'PulStore::Lae::Box' do |b|
    b.barcode { TEST_BARCODES.shift }
    # Rspec wants this:
    b.folders { Array.new(5) { FactoryGirl.create(:lae_core_folder_with_pages) } }
    # Console wants this:
    # after(:create) do |box|
    #   2.times do 
    #     box.folders << FactoryGirl.create(:lae_core_folder_with_pages)
    #   end
    # end
  end
end


