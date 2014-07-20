class ContestsController < ApplicationController
  before_action :only_admin, :only => [:new, :create]

  def index
    @contests = Contest.all
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.create(contest_params)
    if @contest.save
      @contest.problem_ids = contest_params[:problem_ids]
      redirect_to contests_path
    else
      render 'new'
    end
  end

  def show
    @contest = Contest.find(params[:id])
  end

  private

  def contest_params
    params.require(:contest).permit(:title, :start, :end, { :problem_ids => [] })
  end

  def only_admin
    redirect_to contests_path unless signed_in? && current_user.admin?
  end
end
