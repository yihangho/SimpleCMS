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
    store_location
    redirect_to signin_path unless signed_in?
  end

  def not_signed_in_users_only
    redirect_to problems_path if signed_in?
  end

  def current_user_only
    redirect_to problems_path unless signed_in? && current_user?(User.find(params[:id]))
  end
end
