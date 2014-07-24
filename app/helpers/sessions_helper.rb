module SessionsHelper
  def sign_in(user)
    session = user.sessions.new
    remember_token = session.setup_new_remember_token
    session.user_agent = request.user_agent
    session.save

    cookies.permanent[:remember_token] = remember_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = cookies[:remember_token]
    @current_user ||= Session.get_user(remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def sign_out
    @current_user = nil
    session = Session.find_by(:remember_token => Session.hash(cookies[:remember_token]))
    session.delete if session
    cookies.delete(:remember_token)
  end
end
