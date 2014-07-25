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
    @problem = Problem.create(problem_params)
    if @problem.save
      @problem.update_attribute(:setter_id, current_user.id)
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

    puts "Request to update problem #{@problem.id} (#{@problem.title})"

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
        task.save
        current_tasks << task.id
      else
        task = @problem.tasks.create(:input => v[:input], :output => v[:output])

        current_tasks << task.id
        new_tasks     << task.id
      end
    end

    current_tasks.sort!
    @problem.task_ids.each do |id|
      deleted_tasks << id unless current_tasks.bsearch { |x| x >= id }
    end

    deleted_tasks.each do |id|
      @problem.tasks.find(id).delete
    end

    # Kick all these to bg tasks
    tasks_to_be_regraded.each do |id|
      # Not implemented yet
      # Task.find(id).regrade
    end

    if new_tasks.any? || deleted_tasks.any?
      # Recache list of solvers
    end

    render 'show'
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
