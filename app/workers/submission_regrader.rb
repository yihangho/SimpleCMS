class SubmissionRegrader
  include Sidekiq::Worker

  def perform(task_id)
    Task.find(task_id).submissions.each { |s| s.grade }
  end
end
