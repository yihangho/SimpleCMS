# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :seed do
    seed "MyString"
    association :user
    association :task
  end
end
