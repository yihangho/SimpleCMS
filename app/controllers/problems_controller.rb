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
    if @problem.save && @problem.set_permalink(problem_permalink_params)
      tasks_params.each { |_, v| @problem.tasks.create(v) }
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
    @problem.update_attributes(problem_params)
    @problem.set_permalink(problem_permalink_params)

    tasks_to_be_regraded = []
    current_tasks        = []
    deleted_tasks        = []
    new_tasks            = []

    tasks_params.each do |_, v|
      if v[:id] && @problem.task_ids.include?(v[:id].to_i)
        task = @problem.tasks.find(v[:id])

        if task.output != v[:output].to_s
          tasks_to_be_regraded << task.id
        end

        task.input  = v[:input]
        task.output = v[:output]
        task.point  = v[:point]
        task.save
        current_tasks << task.id
      else
        task = @problem.tasks.create(:input => v[:input], :output => v[:output])

        current_tasks << task.id
        new_tasks     << task.id
      end
    end

    current_tasks_set = Set.new(current_tasks)
    @problem.task_ids.each do |id|
      deleted_tasks << id unless current_tasks_set.include?(id)
    end

    deleted_tasks.each do |id|
      @problem.tasks.find(id).delete
    end

    # Kick all these to bg tasks
    tasks_to_be_regraded.each do |id|
      Task.find(id).regrade
    end

    if new_tasks.any? || deleted_tasks.any?
      @problem.update_solvers
    end

    render 'show'
  end

  def show
    @problem = Problem.find(params[:id])
  end

  private
  def problem_params
    params.require(:problem).permit(:title, :statement, :contest_only)
  end

  def tasks_params
    params.require(:problem).require(:tasks).permit!
  end

  def problem_permalink_params
    params.require(:problem).permit(:permalink)[:permalink]
  end

  def authorized_users_only
    unless Problem.find(params[:id]).visible_to?(current_user)
      flash[:danger] = "You are not allowed to view this problem."
      redirect_to problems_path
    end
  end
end
