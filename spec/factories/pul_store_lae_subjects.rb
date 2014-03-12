# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pul_store_lae_subject, :class => 'PulStore::Lae::Subject' do
    value "MyString"
  end
end
