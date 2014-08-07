class SubmissionsController < ApplicationController
  before_action :admin_only, :only => :index
  before_action :signed_in_users_only, :only => :create
  before_action :correct_user_or_admin, :only => :user
  before_action :owner_or_admin, :only => :show

  def index
    @submissions = Submission.order(:created_at => :desc).paginate(:page => params[:page])
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
    @submissions = User.find(params[:id]).submissions.order(:created_at => :desc).paginate(:page => params[:page])
    render 'index'
  end

  private

  def submission_params
    hash = params.require(:submission).permit(:task_id, :input, :code_link , :input_file)
    hash[:input] = hash[:input_file].read unless hash[:input_file].nil?
    hash.permit(:task_id , :input , :code_link)
  end

  def correct_user_or_admin
    if !signed_in?
      store_location
      redirect_to signin_path
    elsif !(current_user?(User.find(params[:id])) || current_user.admin?)
      flash[:danger] = "You can only view your own submissions."
      redirect_to user_submissions_path(current_user)
    end
  end

  def owner_or_admin
    if !signed_in?
      store_location
      redirect_to signin_path
    elsif !(current_user?(Submission.find(params[:id]).user) || current_user.admin?)
      flash[:danger] = "You are not allowed to view this submission."
      redirect_to user_submissions_path(current_user)
    end
  end
end
