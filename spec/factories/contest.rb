FactoryGirl.define do
  factory :contest do
    sequence(:title)  { |n| "Contest #{n}"}
    instructions      "Welcome to this contest."
    start             { 1.day.ago }
    send(:end)        { 1.day.from_now }
    visibility        "public"
    participation     "public"
  end
end
