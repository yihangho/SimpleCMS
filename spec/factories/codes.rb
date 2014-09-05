# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :code do
    user_id 1
    problem_id 1
    code "MyText"
  end
end
