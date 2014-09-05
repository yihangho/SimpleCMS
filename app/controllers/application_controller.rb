class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def admin_only
    if !signed_in?
      store_location
      redirect_to signin_path
    elsif !current_user.admin?
      flash[:danger] = "You are not allowed to access that page."
      redirect_to current_user
    end
  end

  def signed_in_users_only
    unless signed_in?
      respond_to do |format|
        format.html do
          store_location
          redirect_to signin_path
        end

        format.json { render :status => :unauthorized, :json => [] }
      end
    end
  end

  def not_signed_in_users_only
    if signed_in?
      flash[:info] = "You have already signed in!"
      redirect_to current_user
    end
  end

  def current_user_only
    if !signed_in?
      store_location
      redirect_to signin_path
    elsif !current_user?(User.find(params[:id]))
      flash[:danger] = "You are not allowed to access that page."
      redirect_to current_user
    end
  end
end
