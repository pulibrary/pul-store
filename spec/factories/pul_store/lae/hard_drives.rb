TEST_BARCODES ||= YAML.load_file(Rails.root.join('spec/fixtures/test_barcodes.yml'))
FactoryGirl.define do

  factory :lae_hard_drive, :class => 'PulStore::Lae::HardDrive' do |b|
    b.barcode { TEST_BARCODES.pop }
    b.remove_box { true }
  end

end
