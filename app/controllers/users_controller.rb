class UsersController < ApplicationController
  before_action :only_admin, :only => [:index, :set_admin]
  before_action :only_current_user, :only => [:edit, :update]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.create(user_params)
    if @user.save
      sign_in @user
      redirect_to problems_path
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      render 'show'
    else
      render 'edit'
    end
  end

  def set_admin
    @user = User.find(params[:id])
    @user.update_attribute(:admin, set_admin_params)
    render 'show'
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_admin_params
    params.require(:user).require(:admin)
  end

  def only_admin
    redirect_to problems_path unless current_user && current_user.admin?
  end

  def only_current_user
    redirect_to problems_path unless current_user && User.find(params[:id]) == current_user
  end
end
