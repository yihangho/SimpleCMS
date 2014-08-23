class SessionsController < ApplicationController
  before_action :not_signed_in_users_only, :except => [:destroy , :adminlogin]

  def adminlogin
    user = current_user
    if user && user.admin?
      flash[:info] = "You are already logged in as the administrator user"
      redirect_to user
    elsif params[:access_token] == ENV["SIMPLECMS_ADMIN_TOKEN"]
      sign_out if user
      flash.now[:info] = "You have to log in with an admin account to contiue"
      render 'new'
    else
      raise ActionController::RoutingError.new('404 page Not Found')
    end
  end

  def new
    user = User.create!(random_credentials)
    flash[:info] = "I have created a user for you with the username #{user.username}"
    sign_in user
    redirect_to user
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
    if current_user.admin?
      sign_out
      flash[:info] = "You have been logged out"
      redirect_to "/adminlogin?access_token=#{ENV["SIMPLECMS_ADMIN_TOKEN"]}"
    else
      flash[:danger] = "You are not allowed to log out on the demo mode"
      redirect_to current_user
    end
  end

  private

  def session_params
    params.require(:session).permit(:identifier, :password)
  end

  def random_credentials
    def school_name number
      if number == 0
        "school_three"
      elsif number == 1
        "school_one"
      elsif number == 2
        "school_two"
      end
    end
    user_counter = User.count + 1
    {
      :username => "user_#{user_counter}",
      :email => "example_#{user_counter}@example.com",
      :school => "#{school_name(user_counter % 3)}",
      :password => "password",
      :password_confirmation => "password"      
    }
  end
end
