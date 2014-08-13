class ProblemsController < ApplicationController
  before_action :admin_only, :only => [:new, :create, :edit, :update]
  before_action :authorized_users_only, :only => :show

  def index
    @problems = Problem.all
  end

  def new
    @problem = Problem.new
  end

  def create
    @problem = current_user.set_problems.create(problem_params)
    if @problem.save
      render 'show'
    else
      render 'new'
    end
  end

  def edit
    @problem = Problem.find(params[:id])
  end

  def update
    @problem = Problem.find(params[:id])
    if @problem.update_attributes(problem_params)
      render 'show'

      # TODO Implement some smart logic to determine which tasks should get regraded
      @problem.tasks.each { |task| task.regrade }
      # TODO Implement some smart logic to see determine whether we need to perform this
      @problem.update_solvers
    else
      render 'edit'
    end
  end

  def show
    @problem = Problem.find(params[:id])
  end

  private
  def problem_params
    params.require(:problem).permit(:title, :statement, :contest_only, :permalink_attributes => [:url, :_destroy], :tasks_attributes => [:id, :point, :tokens, :input, :output, :_destroy])
  end

  def authorized_users_only
    unless Problem.find(params[:id]).visible_to?(current_user)
      flash[:danger] = "You are not allowed to view this problem."
      redirect_to problems_path
    end
  end
end
