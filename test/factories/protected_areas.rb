# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :protected_area do
    sequence(:wdpa_id) { |n| n }
    legal_status_updated_at Date.new(2014,1,1)
    association :designation, factory: :designation, name: 'My designation'
  end
end
