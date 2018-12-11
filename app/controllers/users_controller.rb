class UsersController < ApplicationController
  before_action :load_user, except: [:index, :new, :create]
  before_action :logged_in_user, except: [:show, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page],
      per_page: Settings.users.paginate.per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      log_in @user
      flash[:success] = t "users.create.success"
      redirect_to @user # equivalent: redirect_to user_url(@user)
    else
      flash.now[:danger] = t "users.create.fail"
      render :new
    end
  end

  def show; end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t "users.update.success"
      redirect_to @user
    else
      flash[:danger] = t "users.update.fail"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "users.destroy.success"
    else
      flash[:danger] = t "users.destroy.fail"
    end
    redirect_to users_path
  end

  private
  def user_params
    params.require(:user).permit :name, :email,
      :password, :password_confirmation
  end

  # Load user from database using id
  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "users.flash.not_found"
    redirect_to login_path
  end

  # Before filters
  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "users.flash.not_logged_in"
    redirect_to login_path
  end

  # Confirm the correct user.
  def correct_user
    return if current_user? @user

    flash[:danger] = t "users.flash.not_correct_user"
    redirect_to root_path
  end

  # Confirms an admin user.
  def admin_user
    return if current_user.admin?

    flash[:danger] = t "user.flash.not_admin"
    redirect_to root_path
  end
end
