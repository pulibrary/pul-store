FactoryGirl.define do
  test_barcodes = Rails.application.config.barcode_list

  factory :lae_hard_drive, :class => 'PulStore::Lae::HardDrive' do |b|
    b.barcode { test_barcodes.pop }
    b.remove_box { true }
  end

end
