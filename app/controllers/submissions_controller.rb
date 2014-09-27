class SubmissionsController < ApplicationController
  before_action :admin_only, :only => [:index, :problem]
  before_action :signed_in_users_only, :only => :create
  before_action :users_allowed_to_submit_only, :only => :create
  before_action :correct_user_or_admin, :only => :user
  before_action :owner_or_admin, :only => :show

  def index
    @submissions = Submission.order(:created_at => :desc).paginate(:page => params[:page])
  end

  def create
    if params.has_key?(:submissions)
      submissions = submissions_params.map do |s|
        current_user.submissions.create(s)
      end

      respond_to do |res|
        res.html { redirect_to submission.task.problem }
        res.json { render :json => submissions }
      end
    else
      submission = current_user.submissions.create(submission_params)
      if submission.save
        if submission.accepted?
          flash[:success] = "Your last submission was correct."
        else
          flash[:danger] = "Your last submission was incorrect."
        end
      end
      redirect_to submission.task.problem
    end
  end

  def show
    @submission = Submission.find(params[:id])
  end

  def user
    @submissions = User.find(params[:id]).submissions.order(:created_at => :desc).paginate(:page => params[:page])
    render 'index'
  end

  def problem
    @submissions = Problem.find(params[:id]).submissions.order(:created_at => :desc).paginate(:page => params[:page])
    render 'index'
  end

  private

  def submissions_params
    params.permit(:submissions => [:task_id, :input, :code])[:submissions] || []
  end

  def submission_params
    params.require(:submission).permit(:task_id, :input, :code)
  end

  def users_allowed_to_submit_only
    if params.has_key?(:submissions)
      ids = submissions_params.map { |x| x[:task_id]}
    else
      ids = [submission_params[:task_id]]
    end

    ids.each do |id|
      unless Task.find(id).allowed_to_submit?(current_user)
        flash[:danger] = "You are not allowed to submit an answer for this task."
        redirect_to Task.find(id).problem
      end
    end
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
