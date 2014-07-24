class ContestsController < ApplicationController
  before_action :admin_only, :only => [:new, :create, :edit, :update]
  before_action :signed_in_users_only, :only => [:participate]
  before_action :authorized_users_only, :only => :show

  def index
    @contests = Contest.all
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = Contest.create(contest_params)
    if @contest.save
      @contest.update_attribute(:creator_id, current_user.id)
      redirect_to contests_path
    else
      render 'new'
    end
  end

  def show
    @contest = Contest.find(params[:id])
  end

  def edit
    @contest = Contest.find(params[:id])
  end

  def update
    @contest = Contest.find(params[:id])
    if @contest.update_attributes(contest_params)
      render 'show'
    else
      render 'edit'
    end
  end

  def participate
    @contest = Contest.find(params[:id])
    @contest.participant_ids |= [current_user.id]
    redirect_to @contest
  end

  private

  def contest_params
    params.require(:contest).permit(:title, :start, :end, :visibility, :participation, { :problem_ids => [] }, { :invited_user_ids => [] })
  end

  def authorized_users_only
    redirect_to contests_path unless Contest.find(params[:id]).visible_to?(current_user)
  end
end
