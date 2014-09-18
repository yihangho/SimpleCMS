json.(@problem, :id, :title, :statement, :stub, :total_points)

json.solved        @problem.solved_by?(current_user)
json.attempted     @problem.attempted_by?(current_user)
json.user_code     @problem.codes.where(:user_id => current_user).take || Code.new, :code
json.points_scored @problem.points_for(current_user)

json.tasks_attributes @problem.tasks do |task|
  json.(task, :id, :order, :label)
  json.input              InputEncoder::Python.encode(task.raw_input(current_user))
  json.submissions_left   task.submissions_left_for(current_user)
  json.submission_allowed task.allowed_to_submit?(current_user)
  json.attempted          task.attempted_by?(current_user)
  json.solved             task.solved_by?(current_user)

  if signed_in? && current_user.submissions.for(task).any?
    json.submission       current_user.submissions.for(task).last, :input, :accepted
  end
end
