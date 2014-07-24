class UsersController < ApplicationController
  before_action :only_admin, :only => [:index, :set_admin]

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
end
