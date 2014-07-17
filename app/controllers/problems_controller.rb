class ProblemsController < ApplicationController
  before_action :correct_user, :only => [:new, :create]

  def index
    @problems = Problem.all
  end

  def new
    @problem = Problem.new
  end

  def create
    @problem = Problem.create(problem_params)
    if @problem.save
      tasks_params.each do |_, v|
        v["problem_id"] = @problem.id
        Task.create(v)
      end
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
    params.require(:problem).permit(:title, :statement)
  end

  def tasks_params
    params.require(:problem).require(:tasks).permit!
  end

  def correct_user
    redirect_to signin_path unless signed_in? and current_user.admin?
  end
end
