class SessionsController < ApplicationController
  before_action :not_signed_in_users_only, :except => :destroy

  def new
  end

  def create
    user = User.find_by(:email => session_params[:email])
    if user && user.authenticate(session_params[:password])
      sign_in(user)
      redirect_to problems_path
    else
      flash.now[:danger] = "Email/password combination incorrect."
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to signin_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
