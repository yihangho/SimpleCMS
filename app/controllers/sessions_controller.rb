class SessionsController < ApplicationController
  before_action :explicit_login , :only => [:new]
  before_action :not_signed_in_users_only, :except => :destroy

  def explicit_login
    user = Session.get_user(params[:token])
    if user
      sign_out # Should not raise any error no matter token belongs to anyone or not
      sign_in user
      flash[:info] = "Logged in as #{user.username}"
      redirect_to user
    end
  end

  def new
  end

  def create
    if session_params[:identifier]["@"] # Supplied email
      user = User.find_by(:email => session_params[:identifier])
    else
      user = User.find_by(:username => session_params[:identifier])
    end

    if user && user.authenticate(session_params[:password])
      sign_in(user)
      redirect_to_stored_location_or user
    else
      flash.now[:danger] = "Wrong email/username and/or password."
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to signin_path
  end

  private

  def session_params
    params.require(:session).permit(:identifier, :password)
  end


end
