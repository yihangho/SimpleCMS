# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :contest_result do
    user ""
    contest ""
    problems_scores ""
    total_score 1
  end
end
