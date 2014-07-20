class SubmissionsController < ApplicationController
  before_action :signed_in, :only => :index

  def index
  end

  def create
    submission = Submission.create(submission_params)
    if submission.save
      if signed_in?
        submission.update_attribute(:user_id, current_user.id)
      end

      if submission.grade
        flash[:success] = "Your last submission was correct."
      else
        flash[:danger] = "Your last submission was incorrect."
      end
    end
    redirect_to submission.task.problem
  end

  def show
    @submission = Submission.find(params[:id])
  end

  private

  def submission_params
    params.require(:submission).permit(:task_id, :input)
  end

  def signed_in
    redirect_to problems_path unless signed_in?
  end
end
