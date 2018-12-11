module SessionsHelper
  # Logs in the given user.
  def log_in user
    session[:user_id] = user.id
  end

  def check_log_in user, params
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        set_remember_forget user, params[:session][:remember_me]
        redirect_back_or user
      else
        message = I18n.t "sessions.helper.flash.not_activated"
        message += I18n.t "sessions.helper.flash.check_email"
        flash[:warning] = message
        redirect_to root_path
      end
    else
      flash.now[:danger] = I18n.t "sessions.helper.flash.invalid_email_pass"
      render :new
    end
  end

  def set_remember_forget user, remember_me
    if remember_me == Settings.sessions.remember_me
      remember user
    else
      forget user
    end
  end

  # Remembers a user in a persistent session.
  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by id: user_id
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the given user is the current user.
  def current_user? user
    user == current_user
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    current_user.present?
  end

  # Forgets a persistent session.
  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  # Logs out the current user.
  def log_out
    forget current_user
    session.delete :user_id
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or default
    redirect_to(session[:forwarding_url] || default)
    session.delete :forwarding_url
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
