class ProblemsController < ApplicationController
  before_action :admin_only, :only => [:new, :create]
  before_action :authorized_users_only, :only => :show

  def index
    @problems = Problem.all
  end

  def new
    @problem = Problem.new
  end

  def create
    @problem = Problem.create(problem_params)
    if @problem.save
      @problem.update_attribute(:setter_id, current_user.id)
      tasks_params.each { |_, v| @problem.tasks.create(v) }
      render 'show'
    else
      render 'new'
    end
  end

  def show
    @problem = Problem.find(params[:id])
  end

  private

  def problem_params
    params.require(:problem).permit(:title, :statement, :visibility)
  end

  def tasks_params
    params.require(:problem).require(:tasks).permit!
  end

  def authorized_users_only
    redirect_to problems_path unless Problem.find(params[:id]).visible_to?(current_user)
  end
end
