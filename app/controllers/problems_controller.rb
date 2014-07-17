class ProblemsController < ApplicationController
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
end
