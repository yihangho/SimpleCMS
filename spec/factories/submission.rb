FactoryGirl.define do
  factory :submission do
    user
    task

    input { task.output }

    factory :incorrect_submission do
      input { task.output + "bla" }
    end
  end
end
