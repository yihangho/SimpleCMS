FactoryGirl.define do
  factory :problem do
    sequence(:title)     { |n| "Problem #{n}"}
    sequence(:statement) { |n| "Problem #{n}"}
    contest_only true

    association :setter, :factory => :admin
  end
end
