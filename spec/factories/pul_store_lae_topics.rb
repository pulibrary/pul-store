# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pul_store_lae_topic, :class => 'PulStore::Lae::Topic' do
    value "MyString"
  end
end
