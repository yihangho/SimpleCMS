class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  private

  def admin_only
    redirect_to problems_path unless signed_in? && current_user.admin?
  end

  def signed_in_users_only
    redirect_to problems_path unless signed_in?
  end

  def not_signed_in_users_only
    redirect_to problems_path if signed_in?
  end

  def current_user_only
    redirect_to problems_path unless signed_in? && current_user?(User.find(params[:id]))
  end
end
