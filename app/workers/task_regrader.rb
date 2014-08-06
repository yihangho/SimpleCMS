class TaskRegrader
  include Sidekiq::Worker

  def perform(task_id)
    Task.find(task_id).regrade
  end
end
