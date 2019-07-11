# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pame_source do
    sequence(:id) { |n| n }
  end
end
