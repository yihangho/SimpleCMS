FactoryGirl.define do
  factory :user do
    sequence(:username) { |n| "User#{n}"}
    sequence(:email)    { |n| "user#{n}@example.com"}
    password "12345"
    password_confirmation "12345"

    factory :admin do
      admin true
    end
  end
end
