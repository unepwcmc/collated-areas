# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pame_evaluation do
    sequence(:id) { |n| n }
    year 2019
    methodology 'My Methodology'
    url 'http://example.com'
  end
end
