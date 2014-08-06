FactoryGirl.define do
  factory :task do
    sequence(:input)     { |n| "Input #{n}"}
    sequence(:output)    { |n| "Output #{n}"}

    problem
  end
end
