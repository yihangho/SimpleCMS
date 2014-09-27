class ContestsController < ApplicationController
  before_action :admin_only, :only => [:new, :create, :edit, :update]
  before_action :signed_in_users_only, :only => [:participate, :invited, :ongoing]
  before_action :authorized_users_only, :only => :show

  def index
    @contests = Contest.all
  end

  def new
    @contest = Contest.new
  end

  def create
    @contest = current_user.created_contests.create(contest_params)
    if @contest.save
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
    @contest.participants << current_user unless @contest.participants.include?(current_user)
    render 'show'
  end

  def unparticipate
    @contest = Contest.find(params[:id])
    @contest.participants.delete(current_user)
    render 'show'
  end

  def leaderboard
    @contest = Contest.find(params[:id])
    render :layout => false if request.xhr?
  end

  def invited
    @contests = Contest.invited_but_not_participated_by(current_user).not_ended
    render 'index', :locals => { :title => "Invited Contests" }
  end

  def ongoing
    @contests = current_user.participated_contests.ongoing
    respond_to do |format|
      format.html { render 'index', :locals => { :title => "Ongoing Contests" } }
      format.json { render :json => @contests }
    end
  end

  private
  def contest_params
    params.require(:contest).permit(:title, :instructions, :start, :end, :visibility, :participation, :permalink_attributes => [:url, :_destroy], :problem_ids => [], :invited_user_ids => [])
  end

  def contest_permalink_params
    params.require(:contest).permit(:permalink)[:permalink]
  end

  def authorized_users_only
    unless Contest.find(params[:id]).visible_to?(current_user)
      flash[:danger] = "You are not allowed to view this contest."
      redirect_to contests_path
    end
  end
end
