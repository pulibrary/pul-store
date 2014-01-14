# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pul_store_lae_box, :class => 'PulStore::Lae::Box' do
    full? false
    tracking_number "MyString"
    shipped_date "2014-01-13 10:09:50"
    received_date "2014-01-13 10:09:50"
    error_note "MyString"
    state "MyString"
    hard_drive_barcode "MyString"
    barcode "MyString"
  end
end
