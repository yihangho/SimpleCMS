FactoryGirl.define do
  factory :problem do
    sequence(:title)     { |n| "Problem #{n}"}
    sequence(:statement) { |n| "Problem #{n}"}
    visibility "public"

    association :setter, :factory => :admin
  end
end
