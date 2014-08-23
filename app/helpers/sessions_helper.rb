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
    user = Session.get_user(remember_token)
    return user unless user.nil?
    user = User.create!(random_credentials)
    sign_in(user)
    user
    # This line is supposed to be the better approach, but it causes
    # a weird bug when using ActiveRecord 4.1.4.
    # TODO check if this bug is still there when newer Rails come out
    # @current_user ||= Session.get_user(remember_token)
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

  def current_user?(user)
    user == current_user
  end

  def sign_out
    @current_user = nil
    session = Session.find_by(:remember_token => Session.hash(cookies[:remember_token]))
    session.delete if session
    cookies.delete(:remember_token)
  end

  def store_location(loc = nil)
    session[:return_to] = loc || (request.url if request.get?)
  end

  def redirect_to_stored_location_or(loc)
    redirect_to(session[:return_to] || loc)
    session.delete(:return_to)
  end
end
