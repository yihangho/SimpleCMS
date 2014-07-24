class SubmissionsController < ApplicationController
  before_action :admin_only, :only => :index
  before_action :signed_in, :only => :create
  before_action :correct_user_or_admin, :only => :user

  def index
    @submissions = Submission.order(:created_at => :desc)
  end

  def create
    submission = Submission.create(submission_params)
    if submission.save
      submission.update_attribute(:user_id, current_user.id)

      if submission.accepted?
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

  def user
    @submissions = User.find(params[:id]).submissions.order(:created_at => :desc)
    render 'index'
  end

  private

  def admin_only
    redirect_to problems_path unless signed_in? && current_user.admin?
  end

  def submission_params
    params.require(:submission).permit(:task_id, :input, :code_link)
  end

  def signed_in
    redirect_to problems_path unless signed_in?
  end

  def correct_user_or_admin
    redirect_to problems_path unless signed_in? && (current_user?(User.find(params[:id])) || current_user.admin?)
  end
end
