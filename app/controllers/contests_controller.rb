class ContestsController < ApplicationController
  def index
    @contests = Contest.all
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.create(contest_params)
    if @contest.save
      redirect_to contests_path
    else
      render 'new'
    end
  end

  private

  def contest_params
    params.require(:contest).permit(:title)
  end
end
