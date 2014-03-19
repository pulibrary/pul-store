# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pul_store_lae_area, :class => 'PulStore::Lae::Area' do
    label "MyString"
    iso_3166_2_code "MyString"
    gac_code "MyString"
  end
end
