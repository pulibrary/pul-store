# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  # this should really be randomized
  # maybe invoke Role Mapper to make the user belongs to the correct groups
  factory :user, :class => User do |u|
    first_name = "Joe"
    last_name = "Test"
    u.email "#{first_name}#{last_name}@university.edu".downcase
    u.password "zzzzzzzzzzzzz"
  end
end
