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
      respond_to do |res|
        res.html { render 'show' }
        res.json { render :json => @problem.to_h(current_user) }
      end
    else
      respond_to do |res|
        res.html { render 'new' }
        res.json { render :json => @problem.to_h(current_user) }
      end
    end
  end

  def edit
    @problem = Problem.find(params[:id])
  end

  def update
    @problem = Problem.find(params[:id])

    if @problem.update_attributes(problem_params)
      # TODO: Determine when to actually regrade
      @problem.tasks.each do |task|
        task.regrade
      end

      @problem.update_solvers

      respond_to do |res|
        res.html { render 'show' }
        res.json { render :json => @problem.to_h(current_user) }
      end
    else
      respond_to do |res|
        res.html { render 'new' }
        res.json { render :json => @problem.to_h(current_user) }
      end
    end
  end

  def show
    @problem = Problem.find(params[:id])
    respond_to do |res|
      res.html {}
      res.json { render :json => @problem.to_h(current_user) }
    end
  end

  private
  def problem_params
    params.require(:problem).permit(:title, :statement, :contest_only, :permalink_attributes => [:url, :_destroy], :tasks_attributes => [:id, :point, :tokens, :input_generator, :grader, :order, :_destroy])
  end

  def authorized_users_only
    unless Problem.find(params[:id]).visible_to?(current_user)
      flash[:danger] = "You are not allowed to view this problem."
      redirect_to problems_path
    end
  end
end
